public class collectionCaseDocuSignCtrl {
    public Case caseRec{get;Set;}
    public id caseId{get;set;}
    public String billingAddress{get;set;}
    Public String product1{get;set;}
    Public String products2{get;set;}
    Public String product3{get;set;}
    public List<wrapperUtility> wrapperList{get;set;}
    //CRM-3476 Used a Label in place of hardcoded value 3
    private static final integer numberOfWrapperClassInUtilityMax=Integer.valueOf(Label.Collection_Case_Payment_Plan_Lines); //3;
    public Double unpaidAmnt{get;set;}
    Public String paymentMthd{get;set;}
    Public String contrtype{get;set;}
    Public String contractsType{get;set;}
    
    public collectionCaseDocuSignCtrl(){
        try{
            caseId=ApexPages.currentPage().getParameters().get('id');
            system.debug('@@@@'+caseId);
            wrapperList=new List<wrapperUtility>();
            for(integer i=0;i<numberOfWrapperClassInUtilityMax;i++){
               wrapperList.add(new wrapperUtility()); 
            }
            
            if(caseId!=null ){
                caseRec=[select Account.email_address__c,id,AccountId,Contact.name,Account.billingAddress,Account.BillingStreet,Account.BillingCity,Account.BillingState,Account.BillingCountry,Account.BillingPostalCode,Contact.Email from Case where id=:caseId and Accountid!=null and Contactid!=null limit 1];
                system.debug(caseRec.Account.BillingStreet);
            }
            if(caseRec!=null){
                system.debug(caseRec.Account.BillingAddress);
                billingAddress+=(caseRec.Account.BillingStreet!=null)?caseRec.Account.BillingStreet+',':'';
                system.debug(billingAddress);
                billingAddress+=(caseRec.Account.BillingCity!=null)?caseRec.Account.BillingCity+',':'';
                system.debug(billingAddress);
                billingAddress+=(caseRec.Account.BillingState!=null)?caseRec.Account.BillingState+',':'';
                system.debug(billingAddress);
                billingAddress+=(caseRec.Account.BillingCountry!=null)?caseRec.Account.BillingCountry+',':'';
                system.debug(billingAddress);
                billingAddress+=(caseRec.Account.BillingPostalCode!=null)?caseRec.Account.BillingPostalCode:'';
                system.debug(billingAddress);
                system.debug(billingAddress);
                billingAddress=billingAddress.remove('null');
                
            }
            
     }
       catch(Exception ex){
         system.debug(ex);   
       }
    }
    
    public List<SelectOption> getProducts(){
        list<SelectOption> productList=new List<SelectOption>{(new SelectOption('','-Select-'))};
        for(Product2 prod:[Select id,Name from Product2 where isActive=true limit 50000]){
            productList.add(
                new SelectOption(prod.name,prod.name)
                );
        }
        return productList;
    }
    public  class wrapperUtility{
        Public Date dueDate{get;set;}
        Public Double dueAmount{get;set;}
        public wrapperUtility(){
        }
    }
    public void sendDataForDocusign(){
        try{
            List<String> wrapperString=new List<String>();
            for(wrapperUtility wr: wrapperList){
                decimal inter=(decimal)wr.dueAmount;
                wrapperString.add(inter.setScale(2)+';'+wr.dueDate);
            }
            system.debug(wrapperString);
            if(caseRec!=null && billingAddress!=null && paymentMthd!=null && contrtype!=null &&unpaidAmnt!=null &&   contractsType!=null && (product1!=null || products2!=null || product3!=null) && wrapperString!=null && !Test.isRunningTest()){
                system.debug('done');
                 //MRB for connections plus  CRM-4853
                if(System.Today() >= Date.valueOf(Label.Connections_Plus_GA_date)){
                   
                    if(product1 == 'Connection(SM) for Co-Brokerage'){
                        product1 = Label.COBROKE_Product_Name2;
                    }
                    if(products2 == 'Connection(SM) for Co-Brokerage'){
                        products2 = Label.COBROKE_Product_Name2;
                    }
                    if(product3 == 'Connection(SM) for Co-Brokerage'){
                        product3 = Label.COBROKE_Product_Name2;
                    }
                }
                //MRB for connections plus code ends
                sendDocusignForPaymentPlan.SendNow(caseRec.AccountId,caseRec.Contact.Name,caseRec.Account.Email_address__c,billingAddress,paymentMthd,contrtype,unpaidAmnt,contractsType,product1,products2,product3,wrapperString,caseRec.Id);
            }
        }
        catch(Exception ex){
            system.debug(ex);
        }
    }
}