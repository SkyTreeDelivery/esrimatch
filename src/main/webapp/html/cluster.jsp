<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>DBSCAN聚类</title>
    <script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
    <link rel="stylesheet" href="https://cache.amap.com/lbs/static/main1119.css" />
    <script type="text/javascript" src="https://webapi.amap.com/maps?v=1.4.15&key=6172ea799c64fdc98eed0bdd4869f3fc">
    </script>
    <script type="text/javascript" src="https://cache.amap.com/lbs/static/addToolbar.js"></script>

    <style>
        #app {
            position: fixed;
            top: 10px;
            left: 10%;
            width: 80%;
            padding: 10px;
            border-radius: 10px;
            border: 1px #ccc solid;
            background: white;
        }
    </style>
</head>

<body>
    <div id="container"></div>
    <div id="app">
        <input type="date" name="" id="" v-model='day'>
        <input type="time" v-model='timeStart'>
        <input type="time" v-model='timeEnd'>
        <label for="c">上车/下车</label>
        <input type="checkbox" id="c" v-model='check'>
        <button @click='main'>开始聚类</button>
    </div>
    <script src="./gcoord.js"></script>
    <script>
        //初始化地图对象，加载地图
        var map = new AMap.Map("container", {
            resizeEnable: true
        });

        var infoWindow = new AMap.InfoWindow({
            offset: new AMap.Pixel(0, -30)
        });
        var markers = [];

        function markerClick(e) {
            infoWindow.setContent(e.target.content);
            infoWindow.open(map, e.target.getPosition());
        }

        var app = new Vue({
            el: '#app',
            data: {
                day: '2016-08-01',
                timeStart: '19:00',
                timeEnd: '23:59',
                check: true,
            },
            methods: {
                main,

            }
        })

        async function main() {
            let check = app.check ? 'start' : 'end';
            let result = await fetch('../track/get_' + check + '_point?day=' + app.day +
                '&timeStart=' + app.day + ' ' + app.timeStart +
                '&timeEnd=' + app.day + ' ' + app.timeEnd);
            result = await result.json();
            if (result.length == 0) {
                alert('获取聚类点失败，请增加点数或更改聚类条件');
                return;
            }
            console.log(result);

            // 对结果根据cid分组
            let cluster_object = {};
            result.forEach(row => {
                let cid = row.cid;
                let x = row.x;
                let y = row.y;
                if (cluster_object[cid] == undefined) {
                    cluster_object[cid] = [
                        [x, y]
                    ];
                } else {
                    cluster_object[cid].push([x, y]);
                }
            });
            console.log(cluster_object);

            // 降纬，取均值
            // [ [[1,1],[2,2]], [[3,3]], [[4,4],[5,5],[6,6]] ]
            let clusters_arr = Object.values(cluster_object);
            // [[1.5,1.5],[3,3],[5,5]]
            let cluster_arr = [];
            clusters_arr.forEach(clusters => {
                let x = 0;
                let y = 0;
                for (const cluster of clusters) {
                    x += cluster[0];
                    y += cluster[1];
                }
                x = x / clusters.length;
                y = y / clusters.length;
                cluster_arr.push([x, y]);
            });
            console.log(cluster_arr);

            // WGS84 To GC02
            cluster_arr = cluster_arr.map(cluster => WGS84ToGCJ02(...cluster));

            // 添加Maker
            map.remove(markers);
            cluster_arr.forEach(async (cluster, index) => {
                var marker = new AMap.Marker({
                    position: cluster,
                    map: map
                });

                // 获取周围POI
                let results = await fetch(
                    'https://restapi.amap.com/v3/place/around?sortrule=weight&key=6172ea799c64fdc98eed0bdd4869f3fc&location=' +
                    cluster.join(',') + '&radius=300&offset=10');
                results = await results.json();
                let pois = results['pois'];
                marker.content = '共' + clusters_arr[index].length + '个点';
                pois.forEach(poi => {
                    marker.content += '<br/>' + poi['name'];
                })
                marker.on('mouseover', markerClick);
                marker.on('mouseout', () => {
                    infoWindow.close()
                })

                // 点数量颜色
                marker.setLabel({
                    offset: new AMap.Pixel(20, 20), //设置文本标注偏移量
                    content: `<div 
                    style=
                    "background:RGB(${clusters_arr[index].length / 100. * 255},20,${(1 - clusters_arr[index].length / 100.) * 255});
                    color:RGB(${(1 - clusters_arr[index].length / 100.) * 255},20,${clusters_arr[index].length / 100. * 255})">
                    共${clusters_arr[index].length}个点</div>`, //设置文本标注内容
                    direction: 'right' //设置文本标注方位
                });

                markers.push(marker);
            });
            map.setFitView();
        }
        main();


        function WGS84ToGCJ02(lon, lat) {
            return gcoord.transform(
                [lon, lat],
                gcoord.WGS84,
                gcoord.GCJ02,
            )
        }
    </script>
</body>

</html>