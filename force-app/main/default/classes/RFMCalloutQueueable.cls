public class RFMCalloutQueueable implements Queueable {
    Set<String> customerIds;

    public RFMCalloutQueueable(Set<String> customerIds) {
        this.customerIds = customerIds;
    }

    public void execute(QueueableContext context) {
        // Call the UnifiedLinkssotIndividualRfm__dlm to fetch matched links
        List<UnifiedLinkssotIndividualRfm__dlm> matchedLinks = [
            SELECT SourceRecordId__c, UnifiedRecordId__c
            FROM UnifiedLinkssotIndividualRfm__dlm
            WHERE SourceRecordId__c IN :customerIds
            AND UnifiedRecordId__c != null
        ];

        System.debug('Unified Link Records: ' + matchedLinks);

        // Prepare the records to be inserted into RFMCustomer__c
        List<RFMCustomer__c> rfmCustomersToInsert = new List<RFMCustomer__c>();
        for (UnifiedLinkssotIndividualRfm__dlm link : matchedLinks) {
            rfmCustomersToInsert.add(new RFMCustomer__c(
                Name = link.SourceRecordId__c,
                Unified_Customer_Id__c = link.UnifiedRecordId__c
            ));
        }

        System.debug('Records to Insert into RFM Customer: ' + rfmCustomersToInsert);

        // Insert the records if the list is not empty
        if (!rfmCustomersToInsert.isEmpty()) {
            insert rfmCustomersToInsert;
        }
        
        
        List<RFMCustomer__c> customers=[SELECT Id,Name,Unified_Customer_Id__c FROM RFMCustomer__c WHERE Name IN:customerIds];
        
        
        if(!customers.isEmpty()){
            List<RFMScoringService.RFMScore> scores=RFMScoringService.calculateRFMForUnifiedIndividuals(customers);
			System.debug('RFM Scores Calculated: ' + scores);
            
        }
        		       
        
    }
}