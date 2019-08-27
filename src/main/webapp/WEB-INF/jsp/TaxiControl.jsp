<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%--引入taglibs.jsp--%>
<%@ include file="taglibs.jsp"%>
<html lang="zh-CN">
<head>
    <base href="//webapi.amap.com/ui/1.0/ui/misc/PathSimplifier/examples/" />
    <meta charset="utf-8">
    <meta name="viewport" content="initial-scale=1.0, user-scalable=no, width=device-width">
    <title>轨迹展示-官方实例</title>
    <style>
        html,
        body,
        #container {
            width: 100%;
            height: 100%;
            margin: 0px;
        }

        #loadingTip {
            position: absolute;
            z-index: 9999;
            top: 0;
            left: 0;
            padding: 3px 10px;
            background: red;
            color: #fff;
            font-size: 14px;
        }
    </style>
</head>

<body>
<div id="container"></div>
<script type="text/javascript" src='//webapi.amap.com/maps?v=1.4.15&key=cfa2cd566d02f475496c9f7d0dd8199b'></script>
<!-- UI组件库 1.0 -->
<script src="//webapi.amap.com/ui/1.0/main.js?v=1.0.11"></script>
<script type="text/javascript">
    //创建地图
    var map = new AMap.Map('container', {
        zoom: 4
    });

    AMapUI.load(['ui/misc/PathSimplifier', 'lib/$'], function(PathSimplifier, $) {

        if (!PathSimplifier.supportCanvas) {
            alert('当前环境不支持 Canvas！');
            return;
        }

        var colors = [
            "#3366cc", "#dc3912", "#ff9900", "#109618", "#990099", "#0099c6", "#dd4477", "#66aa00",
            "#b82e2e", "#316395", "#994499", "#22aa99", "#aaaa11", "#6633cc", "#e67300", "#8b0707",
            "#651067", "#329262", "#5574a6", "#3b3eac"
        ];

        var pathSimplifierIns = new PathSimplifier({
            zIndex: 100,
            //autoSetFitView:false,
            map: map, //所属的地图实例

            getPath: function(pathData, pathIndex) {
                // 这个表明解析的是json数据的path属性
                return pathData.path;
            },
            // 鼠标浮动时的弹出信息
            getHoverTitle: function(pathData, pathIndex, pointIndex) {

                if (pointIndex >= 0) {
                    //point
                    return pathData.name + '，点：' + pointIndex + '/' + pathData.path.length;
                }

                return pathData.name + '，点数量' + pathData.path.length;
            },
            renderOptions: {
                pathLineStyle: {
                    dirArrowStyle: true
                },
                getPathStyle: function(pathItem, zoom) {

                    var color = colors[pathItem.pathIndex % colors.length],
                        lineWidth = Math.round(4 * Math.pow(1.1, zoom - 3));

                    return {
                        pathLineStyle: {
                            strokeStyle: color,
                            lineWidth: lineWidth
                        },
                        pathLineSelectedStyle: {
                            lineWidth: lineWidth + 2
                        },
                        pathNavigatorStyle: {
                            fillStyle: color
                        }
                    };
                }
            }
        });

        window.pathSimplifierIns = pathSimplifierIns;

        $('<div id="loadingTip">加载数据，请稍候...</div>').appendTo(document.body);

        $.getJSON('https://a.amap.com/amap-ui/static/data/big-routes.json', function(d) {

            $('#loadingTip').remove();

            var flyRoutes = [];

            for (var i = 0, len = d.length; i < len; i++) {

                if (d[i].name.indexOf('乌鲁木齐') >= 0) {

                    d.splice(i, 0, {
                        name: '飞行 - ' + d[i].name,
                        // 创建两点之间最短大地线
                        path: PathSimplifier.getGeodesicPath(
                            d[i].path[0], d[i].path[d[i].path.length - 1], 100)
                    });

                    i++;
                    len++;
                }
            }

            d.push.apply(d, flyRoutes);
            // 设定数据源数组，并触发重新绘制
            pathSimplifierIns.setData(d);

            //initRoutesContainer(d);

            function onload() {
                pathSimplifierIns.renderLater();
            }

            function onerror(e) {
                alert('图片加载失败！');
            }

            /**
             * 创建一个轨迹巡航器。
             * pathIndex：关联的轨迹索引
             * options：巡航器的配置选项
             */

            var navg0 = pathSimplifierIns.createPathNavigator(1, {
                loop: true, //循环播放
                speed: 500000
            });

            navg0.start();


            var navg1 = pathSimplifierIns.createPathNavigator(0, {
                loop: true,
                speed: 1000000,
                pathNavigatorStyle: {
                    width: 24,
                    height: 24,
                    //使用图片
                    content: PathSimplifier.Render.Canvas.getImageContent('./imgs/plane.png', onload, onerror),
                    strokeStyle: null,
                    fillStyle: null,
                    //经过路径的样式
                    pathLinePassedStyle: {
                        lineWidth: 6,
                        strokeStyle: 'black',
                        dirArrowStyle: {
                            stepSpace: 15,
                            strokeStyle: 'red'
                        }
                    }
                }
            });

            navg1.start();

            var navg2 = pathSimplifierIns.createPathNavigator(7, {
                loop: true,
                speed: 500000,
                pathNavigatorStyle: {
                    width: 16,
                    height: 32,
                    content: PathSimplifier.Render.Canvas.getImageContent('./imgs/car.png', onload, onerror),
                    strokeStyle: null,
                    fillStyle: null
                }
            });

            navg2.start();

            var navg3 = pathSimplifierIns.createPathNavigator(5, {
                loop: true,
                speed: 500000,
                pathNavigatorStyle: {
                    autoRotate: false, //禁止调整方向
                    pathLinePassedStyle: null,
                    width: 24,
                    height: 24,
                    content: PathSimplifier.Render.Canvas.getImageContent('./imgs/car-front.png', onload, onerror),
                    strokeStyle: null,
                    fillStyle: null
                }
            });

            navg3.start();
        });
    });
</script>
</body>

</html>