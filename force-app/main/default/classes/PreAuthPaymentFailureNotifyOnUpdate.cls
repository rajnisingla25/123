public class PreAuthPaymentFailureNotifyOnUpdate{
    
    Public class EmailFields{
        Public string AccountName;    
        Public string PartyId;    
        Public string Market;    
        Public Datetime InvoicedDate;    
        Public string FailedReason;    
        Public Decimal InvoicedAmount;    
        Public String AcctOwnerEmail;    
    }
    
    Public void VerifyandSendNotification(map<id,Zuora__Payment__c> OldPayments,map<id,Zuora__Payment__c> NewPayments,Boolean Isinsert){
        String AcctOwnerName;
        Map<Id,PreAuthPaymentFailureNotifyOnUpdate.EmailFields> EmailData = New Map<Id,PreAuthPaymentFailureNotifyOnUpdate.EmailFields>();
        List<PreAuthPaymentFailureNotifyOnUpdate.EmailFields> SendData = New List<PreAuthPaymentFailureNotifyOnUpdate.EmailFields>();
        Map<Id,Zuora__Payment__c> errorpymnts 	= new Map<Id,Zuora__Payment__c>();
        Map<Id,Zuora__Payment__c> fltrdpymnts 	= new Map<Id,Zuora__Payment__c>();
        List<Zuora__Payment__c> temppymnts 		= new List<Zuora__Payment__c>();
        Map<id,BigMachines__Quote__c> WLIQuotes = New Map<id,BigMachines__Quote__c>();
        Set<Invoice_Item__c> InvceItems 		= New Set<Invoice_Item__c>();
        List<Orderitem> Orderitems 				= new List<Orderitem>();
        Set<id> AcctIds 		= New Set<id>();
        Set<id> Invceids 		= New Set<id>();
        Set<id> AssetIds 		= New Set<id>();
        Set<id> OrderitemIds 	= New Set<id>();
        Set<id> OrdQuoteIds 	= New Set<id>();
            system.debug('NewPayments.values():'+NewPayments.values());
        
        Try{
            For(Zuora__Payment__c newpymntlp : NewPayments.values()){
                If(newpymntlp.Zuora__Status__c  == 'Error' && Isinsert){
                    errorpymnts.put(newpymntlp.Zuora__Account__c,newpymntlp);
                    AcctIds.add(newpymntlp.Zuora__Account__c);
                }Else If(!Isinsert && newpymntlp.Zuora__Status__c  == 'Error' && OldPayments.get(newpymntlp.id).Zuora__Status__c != 'Error'){
                    errorpymnts.put(newpymntlp.Zuora__Account__c,newpymntlp);
                    AcctIds.add(newpymntlp.Zuora__Account__c);
                }
            }
            system.debug('errorpymnts:'+errorpymnts);
            system.debug('AcctIds:'+AcctIds);
            If(!AcctIds.isEmpty()){
                Map<Id,Waitlist_Item__c> WLIMap = New Map<Id,Waitlist_Item__c>([Select Account__c,Account__R.Name,Account__R.Party_id__c,Account__R.Owner.email,Account__R.Owner.Name,Market__c,(Select id from Quotes__r) From Waitlist_Item__c 
                                                                                where Account__c In : AcctIds And Wailist_Type__c  = 'Pre-Auth' And
                                                                                Rank__C = 1 AND Status__C = 'Active']);
                system.debug('WLIMap:'+WLIMap);
                For(Waitlist_Item__c WLIlp : WLIMap.values()){
                    PreAuthPaymentFailureNotifyOnUpdate.EmailFields TempData = New PreAuthPaymentFailureNotifyOnUpdate.EmailFields();
                    If(!WLIlp.Quotes__r.isEmpty()){
                        temppymnts.add(errorpymnts.get(WLIlp.Account__c));
                        WLIQuotes.putall(WLIlp.Quotes__r);
                        AcctOwnerName			= WLIlp.Account__R.Owner.Name;
                        TempData.AccountName 	= WLIlp.Account__R.Name;
                        TempData.PartyId 		= WLIlp.Account__R.Party_id__c;
                        TempData.AcctOwnerEmail	= WLIlp.Account__R.Owner.email;
                        TempData.Market 		= WLIlp.Market__c;
                        TempData.InvoicedDate 	= errorpymnts.get(WLIlp.Account__c).CreatedDate;
                        TempData.FailedReason 	= errorpymnts.get(WLIlp.Account__c).Zuora__GatewayResponse__c;
                        TempData.InvoicedAmount = errorpymnts.get(WLIlp.Account__c).Zuora__Amount__c;
                        For(BigMachines__Quote__c Bigqtlp : WLIlp.Quotes__r){
                            EmailData.put(Bigqtlp.id,TempData);
                        }
                    }
                }
                fltrdpymnts.putall(temppymnts);
                system.debug('fltrdpymnts:'+fltrdpymnts);
                
                If(!fltrdpymnts.isEmpty()){
                    //Query Invoices from Invoice payments object for Payments
                    List<Zuora__PaymentInvoice__c> InvcePyments = [Select Zuora__Invoice__c from Zuora__PaymentInvoice__c 
                                                                   Where Zuora__Payment__c In : fltrdpymnts.Keyset()];
                    
                    For(Zuora__PaymentInvoice__c Invpymntlp : [Select Zuora__Invoice__c  from Zuora__PaymentInvoice__c 
                                                               Where Zuora__Payment__c in : fltrdpymnts.Keyset()]){
                                                                   Invceids.add(Invpymntlp.Zuora__Invoice__c);                                                       
                                                               }
                    
                    //Query invoiceItems from Invoices
                    For(Zuora__ZInvoice__c Invcelp : [Select id,(Select id, Asset__c from Invoice_Items__r) From Zuora__ZInvoice__c
                                                      where id In : Invceids]){
                                                          InvceItems.addall(Invcelp.Invoice_Items__r);
                                                      }
                    
                    For(Invoice_Item__c InvItemlp : InvceItems){
                        AssetIds.add(InvItemlp.Asset__c);                                    
                    }
                    
                    //Query Assets from InvoiceItems
                    For(Asset Astlp : [Select Id,Market__c, Order_Line_Item__c,(select id from Order_Products__r) From Asset Where Id In :AssetIds]){
                        orderitems.addall(Astlp.Order_Products__r);
                    }
                    system.debug('orderitems:' + orderitems);
                    
                    For(orderitem orditmlp : orderitems){
                        OrderitemIds.add(orditmlp.id);
                    }
                    system.debug('OrderitemIds:' + OrderitemIds);
                    system.debug('EmailData.keySet:' + EmailData.keySet());
                    //Query Orders,Quotes from OrderItems
                    For(OrderItem OrdItemlp : [Select Id,Order.Oracle_Quote__c From OrderItem Where Id In : OrderitemIds]){
                        system.debug('OrdItemlp.Order.Oracle_Quote__c:'+ OrdItemlp.Order.Oracle_Quote__c);
                        If(EmailData.keySet().contains(OrdItemlp.Order.Oracle_Quote__c)){
                            SendData.add(EmailData.get(OrdItemlp.Order.Oracle_Quote__c)); 
                        }
                    }
                    
                    If(!SendData.isEmpty()){
                        Set<PreAuthPaymentFailureNotifyOnUpdate.EmailFields> removedups = New Set<PreAuthPaymentFailureNotifyOnUpdate.EmailFields>(SendData);
                        SendData.clear();
                        SendData.addall(removedups);
                        String htmlBody = 'Hi '+AcctOwnerName +', <br><br> Below Account Waitlist Pre-Auth Payment is failed, Please take necessary steps.';
                        String[] toAddresses = new String[] {SendData[0].AcctOwnerEmail};
                        String[] ccAddresses = label.PaymentFailCCEmail.split(',');
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setToAddresses(toAddresses);
                        email.setCcAddresses(ccAddresses);
                        email.setSubject('Pre-Auth Payment Failed for the customer :' + SendData[0].AccountName);
                        
                        htmlBody += '<br><br><table width="auto" border="1" style="border-collapse: collapse"><tr><th>Account Name</th><th>Party Id</th><th>Market</th><th>Invoiced Amount</th><th>Invoiced Date</th><th>Failed Reason</th></tr>';
                        for(PreAuthPaymentFailureNotifyOnUpdate.EmailFields emldatalp : SendData){
                            String AccountName 		= emldatalp.AccountName;
                            String PartyId 			= emldatalp.PartyId;
                            String Market 			= emldatalp.Market;
                            Datetime InvoicedDate 	= emldatalp.InvoicedDate;
                            Decimal InvoicedAmount 	= emldatalp.InvoicedAmount;
                            String FailedReason 	= emldatalp.FailedReason;
                            htmlBody += '<tr><td>' + AccountName + '</td><td>' + PartyId + '</td></td>'+ Market + '</td></td>'+ InvoicedAmount + '</td></td>'+ InvoicedDate + '</td></td>'+ FailedReason + '</td></tr>';
                        }
                        htmlBody += '</table>';
                        email.setHtmlBody(htmlBody);
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                    }
                }
            }
        } Catch(exception ex){
            Error__c error 				= new Error__c();
            error.Name 					= 'PreAuthPaymentFailureNotifyOnUpdate';
            error.Entity_Id__c 			= string.valueof(AcctIds);
            error.Interface_Name__c 	= 'Inside SFDC';
            error.Error_Description__c 	= 'Message:'+ex.getMessage()+'$$$'+'Stack trace:'+ex.getStackTraceString();
            insert error;            
        }
    }
    
}