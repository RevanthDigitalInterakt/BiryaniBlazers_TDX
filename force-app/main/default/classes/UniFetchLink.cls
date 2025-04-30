public class UniFetchLink {

    // Wrapper class to accept input from Flow
    public class InputWrapper {
        @InvocableVariable(required=true label='Number of Days')
        public Integer numberOfDays;
    }

    // NEW: Wrapper class for Output to Flow
    public class OutputWrapper {
        @InvocableVariable(label='Status Message')
        public String statusMessage;
    }

    // Expose method to Flow
    @InvocableMethod(label='UniFetchLink APEX')
    public static List<OutputWrapper> run(List<InputWrapper> inputs) {
        List<OutputWrapper> outputs = new List<OutputWrapper>();
        
        for (InputWrapper input : inputs) {
            if (input.numberOfDays != null && input.numberOfDays > 0) {
                refreshSalesOrders(input.numberOfDays);
                
                // prepare output
                OutputWrapper output = new OutputWrapper();
                output.statusMessage = 'RFM preparation started for last ' + input.numberOfDays + ' days.';
                outputs.add(output);
            } else {
                throw new AuraHandledException('Please provide a valid number of days greater than 0.');
            }
        }
        return outputs;
    }

    // Main logic to fetch and refresh Sales Orders
    public static void refreshSalesOrders(Integer NO_OF_DAYS) {
        Date startDate = Date.today().addDays(-NO_OF_DAYS);
        List<ssot__SalesOrder__dlm> orders = [
            SELECT ssot__Id__c, ssot__SoldToCustomerId__c, ssot__PurchaseOrderDate__c,
                   STORE_CITY__c, ssot__GrandTotalAmount__c
            FROM ssot__SalesOrder__dlm
            WHERE ssot__PurchaseOrderDate__c >= :startDate
        ];
	
                // Delete existing Sales Orders
        delete [SELECT Id FROM Sales_Order__c];

        List<Sales_Order__c> newOrders = new List<Sales_Order__c>();
        Set<String> customerIds = new Set<String>();

        for (ssot__SalesOrder__dlm order : orders) {
            if (String.isNotBlank(order.ssot__SoldToCustomerId__c)) {
                newOrders.add(new Sales_Order__c(
                    Name = 'SO-' + order.ssot__Id__c,
                    Customer_Id__c = order.ssot__SoldToCustomerId__c,
                    Order_Date__c = order.ssot__PurchaseOrderDate__c,
                    STORE_N__c = order.STORE_CITY__c,
                    Total_Amount__c = order.ssot__GrandTotalAmount__c
                ));
                customerIds.add(order.ssot__SoldToCustomerId__c);
            }
        }

        if (!newOrders.isEmpty()) insert newOrders;

        System.enqueueJob(new RFMDeleteQueueable());
        System.enqueueJob(new RFMCalloutQueueable(customerIds));
    }
}