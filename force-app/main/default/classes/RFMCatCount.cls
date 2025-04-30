global with sharing class RFMCatCount {

    @InvocableMethod(label='Fetch Top 5 RFM Metrics Category By Count')
    global static List<List<RFMCatCountOutput>> fetchtop5RFMCat (List<Requestv2> req) {
        List<AggregateResult> metricsList = new List<AggregateResult>();

        if (req != null && !req.isEmpty() && req[0].varType1 == 'RFM') {
            metricsList = [
                SELECT COUNT(Unified_Customer_ID__c) totalCount,
                       RFM_Category__c 
                FROM RFMMetrics__c
                GROUP BY RFM_Category__c 
                ORDER BY COUNT(Unified_Customer_ID__c) DESC
                LIMIT 5
            ];
        }

        List<List<RFMCatCountOutput>> outputResponse = new List<List<RFMCatCountOutput>>();
        List<RFMCatCountOutput> responses = new List<RFMCatCountOutput>();

        for (AggregateResult metric : metricsList) {
            RFMCatCountOutput response = new RFMCatCountOutput();
            response.catcount = String.valueOf(metric.get('totalCount')); // Cast to String to avoid Experience error
            response.rfmCategory = (String) metric.get('RFM_Category__c');
            responses.add(response);
        }

        outputResponse.add(responses);
        return outputResponse;
    }

    global class Requestv2 {
        @InvocableVariable(required=true)
        global String varType1;  // Always "RFM"
    }

    
}