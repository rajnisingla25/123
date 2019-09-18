global class Z_CreateBillingAccount  implements Schedulable {
  String orderId;
  String zBillingAccountId;
  String sfdcAccountId;
 
  public Z_CreateBillingAccount(String orderId, String sfdcAccountId, String zBillingAccountId) {
    this.orderId = orderId;
    this.sfdcAccountId = sfdcAccountId;
    this.zBillingAccountId = zBillingAccountId;
  }

  global void execute(SchedulableContext sc)
  {
    OrderDecompController.convertOrderLines(orderId, sfdcAccountId, zBillingAccountId);
  }
}