global with sharing class RFMMetrics {

    @InvocableMethod(label='Fetch RFM Metrics by Category ')
    global static List<List<RFMResponseMetrics>> fetchRFMMetrics(List<Request> req) {
        List<RFMMetrics__c> metricsList = new List<RFMMetrics__c>();

        if (req[0].varType2 != null) {
            metricsList = [
                SELECT Unified_Customer_ID__c,
                       RFM_Category__c,
                       RFM_Combined_Score__c
                FROM RFMMetrics__c
                WHERE RFM_Category__c = :req[0].varType2
                LIMIT 5
            ];
        }

        List<List<RFMResponseMetrics>> outputResponse = new List<List<RFMResponseMetrics>>();
        List<RFMResponseMetrics> responses = new List<RFMResponseMetrics>();

        for (RFMMetrics__c metric : metricsList) {
            RFMResponseMetrics response = new RFMResponseMetrics();
            response.unifiedCustomerId = metric.Unified_Customer_ID__c;
            response.rfmCategory = metric.RFM_Category__c;
            response.combinedScore = metric.RFM_Combined_Score__c != null ? String.valueOf(metric.RFM_Combined_Score__c) : null;
            responses.add(response);
        }

        outputResponse.add(responses);
        return outputResponse;
    }
    global class Request {
             
            
            @InvocableVariable(required=true)
            global String varType2; 
        }
    
}