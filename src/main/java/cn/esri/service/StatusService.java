package cn.esri.service;

import cn.esri.vo.*;
import net.sf.json.JSONObject;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;
import java.util.Map;

@Service
public interface StatusService {

    List<Status> searchByDistinct(DistinctQuery distinctQuery);

    JSONObject flowAnalyse(DistinctQuery distinctQuery);

    List<String> createBuffers(PolylinesQuery polylinesQuery);

    List<Status> searchByBuffers(BuffersQuery buffersQuery);

    public Map<String, List<List<Status>>> searchPickUpSpotStatusData(PredictQuery predictQuery);

    public Map<String, List<Integer>> searchPickUpSpotCount(PredictQuery predictQuery) ;

    Map<Integer,Map<String,Double>> predictByStatus(Map<Integer,Map<String,List<Status>>> boxStatusData,PredictQuery predictQuery);

    Map<String, List<Integer>> predictByCount(Map<String, List<Integer>> boxStatusData,PredictQuery predictQuery);

    List<Integer> searchCarIdByTime(Date time);


}
