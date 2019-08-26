<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@include file="taglibs.jsp"%>
<html>
<head>
    <title>总体统计</title>
    <style>
        .allDataBar{
            width: 700px;
            height:400px;
        }
        .allDataPie{
            width: 700px;
            height:400px;
        }


    </style>
    <script src="${path}/js/echarts.min.js"></script>
    <script>

        $(function(){
            //注册鼠标点击事件
            $("#sub").click(function () {
                var time = $("#date").val();
                console.log(time);
                $.ajax({
                    method: "POST",
                    timeout: 5000,
                    contentType:"application/x-www-form-urlencoded",
                    dataType:"json",
                    url: path + "/data/ajax_getDataByTime.action",
                    data:{
                        "date":time
                    },
                    async: true,
                    success: function (result) {
                        //预处理数据
                        for(var key in result){
                            //处理距离
                            result[key][0] = parseFloat(result[key][0].toFixed(2));
                            //处理时间转为小时
                            result[key][1] = parseFloat((result[key][1]/1000/3600).toFixed(2));
                            // 过滤数据
                            if(result[key][0] > 1000){
                                delete result[key];
                            }
                        }
                        initSingleDataBar(result, time, "distance");
                        initSingleDataBar(result, time, "time");
                        initSingleDataBar(result, time, "num");

                        //获得最大的10个车
                        var k = 10;
                        initSingleDataPie(result, k, time, "distance");
                        initSingleDataPie(result, k, time, "time");
                        initSingleDataPie(result, k, time, "num");
                    },
                    error: function (errorMessage) {
                        alert("XML request Error");
                    }
                });
            });
        });
    </script>


    <script>



        function initSingleDataPie(result, k, time, type){
            // 基于准备好的dom，初始化echarts实例
            var colum = 0;//默认距离
            var title = ["距离","(KM)"];
            var divId = "maxDistance";
            switch (type){
                case "distance":
                    colum = 0;
                    title = ["行驶距离","(公里)"];
                    divId = "maxDistance";
                    break;
                case "time":
                    colum = 1;
                    title = ["接客时长","(小时)"];
                    divId = "maxTime";

                    break;
                case "num":
                    colum = 2;
                    title = ["接客次数","(次)"];
                    divId = "maxNum";
                    break;
            }
            var myChart = echarts.init(document.getElementById(divId));
            var maxKeyList = getMaxKeyList(result, k, type);
          var data = {
              legendData:[],
              selected:[],
              seriesData:[]
          };
          for(var key in maxKeyList){
            data.legendData.push(maxKeyList[key]);
            data.selected.push(true);
            data.seriesData.push(
                {
                    name:maxKeyList[key],
                    value:result[maxKeyList[key]][colum]
                });
          }
          var option = {
                title : {
                    text: title[0]+'最大'+"的前"+k+"辆车"+title[1],
                    x:'center'
                },
                tooltip : {
                    trigger: 'item',
                    formatter: "{a} <br/>{b} : {c} ({d}%)"
                },
                legend: {
                    type: 'scroll',
                    orient: 'vertical',
                    right: 10,
                    top: 20,
                    bottom: 20,
                    data: data.legendData,
                    selected: data.selected
                },
                series : [
                    {
                        name: '详细信息',
                        type: 'pie',
                        radius : '55%',
                        center: ['40%', '50%'],
                        data: data.seriesData,
                        itemStyle: {
                            emphasis: {
                                shadowBlur: 10,
                                shadowOffsetX: 0,
                                shadowColor: 'rgba(0, 0, 0, 0.5)'
                            }
                        }
                    }
                ]
             };
            myChart.setOption(option);
        }

        //初始化总体统计的距离、时间、接客次数图标,type=distance or time or num
        function initSingleDataBar(result, time, type){
            var colum = 0;//默认距离
            var title = ["行驶距离","(公里)"];
            var divId = "allDistance";
            switch (type){
                case "distance":
                    colum = 0;
                    title = ["行驶距离","(公里)"];
                    divId = "allDistance";
                    break;
                case "time":
                    colum = 1;
                    title = ["接客时长","(小时)"];
                    divId = "allTime";

                    break;
                case "num":
                    colum = 2;
                    title = ["接客次数","(次)"];
                    divId = "allNum";
                    break;
            }

            // 基于准备好的dom，初始化echarts实例
            var myChart = echarts.init(document.getElementById(divId));
            // 预处理数据
            var idData = [];
            var singleData = [];
            for(var key in result){
                // 过滤数据
                idData.push(key);
                singleData.push(result[key][colum]);
            }
            var option = {
                title: {
                    text: time+'所有车辆'+title[0]+'统计'+title[1],
                    left: 10
                },
                toolbox: {
                    feature: {
                        dataZoom: {
                            yAxisIndex: false
                        },
                        saveAsImage: {
                            pixelRatio: 2
                        }
                    }
                },
                tooltip: {
                    trigger: 'axis',
                    axisPointer: {
                        type: 'shadow'
                    }
                },
                grid: {
                    bottom: 90
                },
                dataZoom: [{
                    type: 'inside'
                }, {
                    type: 'slider'
                }],
                xAxis: {
                    data: idData,
                    silent: false,
                    splitLine: {
                        show: false
                    },
                    splitArea: {
                        show: false
                    }
                },
                yAxis: {
                    splitArea: {
                        show: false
                    }
                },
                series: [{
                    type: 'bar',
                    data: singleData,
                    // Set `large` for large data amount
                    large: true
                }]
            };
            // 使用刚指定的配置项和数据显示图表。
            myChart.setOption(option);
        }

        // 求最大k个json的key
        function getMaxKeyList(result,k,type){
            var colum = 0;//默认距离
            switch (type){
                case "distance":
                    colum = 0;
                    break;
                case "time":
                    colum = 1;
                    break;
                case "num":
                    colum = 2;
                    break;
            }
            var keyList = [];
            for (var i=0;i<k;i++){
                var maxKey = "";
                var maxSingleData = -Infinity;
                for(var key in result){
                    var singleData = result[key][colum];
                    if((keyList.indexOf(key) === -1) && (singleData > maxSingleData)){
                        maxSingleData = singleData;
                        maxKey = key;
                    }
                }
                keyList.push(maxKey);
            }
            return keyList;
        }
    </script>

</head>
<body>
    <input type="date" name="date" id="date" value="2016-08-01">
    <input type="button" name="sub" id="sub" value="查询">
    <div id="allDistance" class="allDataBar"></div>
    <div id="allTime" class="allDataBar"></div>
    <div id="allNum" class="allDataBar"></div>
    <div id="maxDistance" class="allDataPie"></div>
    <div id="maxTime" class="allDataPie"></div>
    <div id="maxNum" class="allDataPie"></div>
</body>
</html>
