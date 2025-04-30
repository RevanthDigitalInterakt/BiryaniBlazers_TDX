public class RFMDeleteQueueable implements Queueable {
    public void execute(QueueableContext context) {
       
        String query='SELECT Id FROM RFMCustomer__c';
        List<RFMCustomer__c> customerdelete=Database.query(query);
        if (!customerdelete.isEmpty()) {
            delete customerdelete;
            System.debug('Deleted RFMCustomer records');
        } else {
            System.debug('No RFMCustomer records found to delete');
        }
        System.debug('Deleted RFMCustomer records');
    }
}