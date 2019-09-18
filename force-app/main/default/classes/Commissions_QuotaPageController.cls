/*******************************************************************************
Created By         :   Srinivas Pendli
Created Date       :   1-Oct-2016
Usage              :   The purpose of this class/Page is to perform kicker logic based on the business logic.

MODIFICATION DETAILS    :   
1. Modified By     :   Srinivas Pendli on 18-Oct-2016 for CRM-420.
2. Modified By     :   Sandeep Meka on 15-Nov-2016, modified License Count and Unit Achievement calculation and display
3. Modified By     :   Srinivas Pendli on 17-Nov-2016, added code comments
********************************************************************************/
public without sharing class Commissions_QuotaPageController{
    //VARIALBLE DECLERATION
    public list<wrapQuota> wrapQuotaList { get; set; }
    public list<wrapQuota> wrapQuotaListTemp { get; set; }    
    public list<wrapQuota> wrapQuotaListKicker { get; set; }
    public list<Quota_Product__c> allProducts {get;set;} 
   // public list<Quota_Product__c> allProductsTemp {get;set;} 
    Map<id,Quota_Product__c> allProductsTemp1 = new Map<id,Quota_Product__c>();
    public Map<String,Boolean> mapPBoolean{get;set;} 
    ID RecordId{get;set;}
    ID RecordId1;
    Integer i = 0;
    public Boolean allBool {get;set;}    
    public Boolean show{get;set;}   
    public boolean isError{get;set;} 
    public string callfunc{get;set;}
    //CONSTRUCTOR
    Map<String,String> mapString = new Map<String,String>();
    Map<String,String> mapString1 = new Map<String,String>();
    List<Commission__c> commissionRecordsTemp = new  List<Commission__c>();
    //public list<Quota_Product__c> allProductsTemp {get;set;} 
    list<Quota_Product__c> allProductsTemp = new list<Quota_Product__c>();
    public Commissions_QuotaPageController(ApexPages.StandardController controller) {
        allBool = false;
        wrapQuotaList = new list<wrapQuota>();
        mapPBoolean = new Map<String,Boolean>();
        wrapQuotaListTemp = new list<wrapQuota>();
        //Retrive current quota record id
        RecordId = ApexPages.currentPage().getParameters().get('id');   
        //Retriving all related quota productions from 'Quota_Product__c' object.     
        allProductsTemp = [select id,Name,Product_Name__c,CreatedDate,Product_Family__c ,Product_Name__r.Name,Sales__c,Sales_Achivement__c,License__c,Unit__c,Unit_Achivement__c,
                          License_Achivement__c,Target__c,Related_To_Quota__c,Product_Name1__c
                          from Quota_Product__c where Related_To_Quota__c =: RecordId Order by CreatedDate Desc];
        system.debug('RecordId :'+RecordId);
        
        
        //Retriving all Related commissions (Related asset line type only 'add' and 'Amend') from 'Commissions__C' Object              
        commissionRecordsTemp = [select id,Name,Total_Commissionable_Amount__c,Product__c,Product__r.Name,product__r.Product_Family__c,Related_to_Quota__c,other_Product__c 
                                                    from Commission__c where (line_type__c = 'Add' OR (line_type__c = 'Amend' AND RecordType.Name!= 'Clawback')) and Related_to_Quota__c =: RecordId ]; 
                        //Commission__c where Related_to_Asset__r.line_type__c = 'Add' and Related_to_Quota__c =: RecordId];        
        system.debug('commissionRecords $$ 1:'+commissionRecordsTemp .size());
        system.debug('allProductsTemp >>:'+allProductsTemp );
        //Calculating Sales Achivement of each product,for related quota only
        for(Quota_Product__c prod : allProductsTemp){
            system.debug('Prod :'+Prod);
            i = i+1;
            prod.Sales_Achivement__c = 0;
            prod.License_Achivement__c = 0;
            prod.Unit_Achivement__c = 0;            
            for(Commission__c comm : commissionRecordsTemp){
                system.debug('>>>>>>>>> 0:'+comm.Name);
                system.debug('>>>>>>>>> 1:'+prod.createdDate);
                system.debug('>>>>>>>>> 2:'+comm.Product__r.Product_Family__c);
                
                if((prod.Product_Name__c == comm.Product__c) || (prod.Product_Family__c  == comm.Product__r.Product_Family__c )){
                    prod.Sales_Achivement__c = prod.Sales_Achivement__c+comm.Total_Commissionable_Amount__c; 
                    if(comm.Product__r.Product_Family__c != Null){
                        if(prod.Product_Name__c == Null){
                            prod.Product_Family__c = comm.Product__r.Product_Family__c ;
                        }
                    }
                }
            }
            
            wrapQuota wq = new wrapQuota();
            wq.isSelected = false;
            wq.quotaprds =  prod;
            wq.tempValue = 'P'+i;
            wrapQuotaList.add(wq);
            mapString.put(prod.Product_Name1__c,prod.Product_Name1__c);            
        }       
        MyMethod();
        for(Quota_Product__c q : allProductsTemp){
            allProductsTemp1.put(q.Product_Name__c,q);
            if(q.Product_Family__c != null){
            mapString1.put(q.Product_Family__c ,q.id);
            }
        }
    }
    //Adding new product for related quota
    public void addrow(){
        system.debug('wrapQuotaList :'+wrapQuotaList);
        Quota_Product__c a = new Quota_Product__c();
        wrapQuota wq = new wrapQuota();
        wq.isSelected = false;
        wq.quotaprds =  a;
        wq.tempValue = 'P'+(wrapQuotaList.size()+1);
        wrapQuotaList.add(wq);
        mapPBoolean.put(wq.tempValue,false);
    }
    //deleting added products of related quota from page.
    public void deleteRow(){       
        List<Quota_Product__c> listquotaProductsForDel = new List<Quota_Product__c>();
        List<wrapQuota> listTempWrapper = new List<wrapQuota>();
        for(wrapQuota w : wrapQuotaList ) {
            if(w.isselected) {
                listquotaProductsForDel.add(w.quotaprds);
            } 
            else {                
                listTempWrapper.add(w);
            }
        }
        if(listquotaProductsForDel.size() > 0) {
        try{
            delete listquotaProductsForDel;
            }Catch(Exception e){}
            allBool = false;
            wrapQuotaList = listTempWrapper;
        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Test Error'));
        }   
    }  
    //select all available products
    public void selectAll(){
        if(allBool) {
            for(wrapQuota w : wrapQuotaList) {
                w.isselected = true;
            }
        }
        else {
            for(wrapQuota w : wrapQuotaList) {
                w.isselected = false;
            }
        }
    }
    //Cancel
    public PageReference Cancel(){
        PageReference home = new PageReference('/apex/Commissions_QuotaPageControllerRead?id='+RecordId);
        home.setRedirect(true);
        return home;
    } 
         
    //The functionality of this method is to calculating 'asset License Count', 'asset Units Count', 'Sales Achivement' and 'target' of each product.    
    public PageReference MyMethod(){
        List<Commission_Products__c> commprod = Commission_Products__c.getall().values();
        //List<Product_Family__c> productFamilies = Product_Family__c.getall().values();
       
        RecordId1 = ApexPages.currentPage().getParameters().get('id');
        wrapQuotaListTemp = wrapQuotaList;   
        system.debug('wrapQuotaListTemp $$ :'+wrapQuotaListTemp );
        system.debug('wrapQuotaList $$ :'+wrapQuotaList);     
        //set<string> assetNames = new set<string>();
        List<Commission__c> commissionRecords = [select id,Name,Related_to_Asset__c,Related_to_Asset__r.License_Tier__c,Total_Commissionable_Amount__c,Commission__c.Signing_AE__c,Related_to_Quota__r.User__c,
                                                Product__c,Product__r.Name,Related_to_Quota__c,Related_to_Asset__r.Name,Related_to_Asset__r.line_type__c,other_Product__c 
                                                from Commission__c where (line_type__c = 'Add' OR (line_type__c = 'Amend' AND RecordType.Name!= 'Clawback')) and Related_to_Quota__c =: RecordId];
        system.debug('commissionRecords $$ :'+commissionRecords.size());
        List<String> ProductNames = new List<String>();
        Integer assetUnitsCount = 0;
        Integer assetLicenseCount = 0;
        //Calculating 'asset License Count' of related quota
        for(commission__c comm : commissionRecords){          
            ProductNames.add(comm.Product__r.Name);            
            //assetNames.add(comm.Related_to_Asset__r.Name);  
            if(comm.Other_Product__c != Null){
                for(Commission_Products__c commp : commProd){
                    if(comm.other_product__c == commp.Other_Product_Name__c){
                        ProductNames.add(commp.Name);
                    }                    
                }
            }         
        }
        //Calculating 'asset Units Count ' of related quota     
        Map<id,Product2> allProducts = new Map<id,Product2>([select id,Name,Product_Family__c from Product2 where Name IN : ProductNames]);
        
        //calculatong 'asset License Count', 'asset Units Count', 'Sales Achivement' and 'target' of each product.    
        for(wrapQuota w : wrapQuotaListTemp){
            w.quotaprds.Sales_Achivement__c = 0; w.quotaprds.License_Achivement__c = 0; w.quotaprds.Unit_Achivement__c = 0;            
            assetLicenseCount = 0; assetUnitsCount =0;
            boolean productExisted = false;
            //CALCULATING LICENSE COUNT
            /***
            for(Commission__c comm : commissionRecords){
                Product2 prod1 =  allProducts.get(comm.Product__c);
                if((comm.Product__c != null && w.quotaprds.Product_Name__c == prod1.id)){ 
                    if(comm.Related_to_Asset__r.License_Tier__c != Null && Comm.Product__r.Name ==  prod1.name ){
                        assetLicenseCount = assetLicenseCount+Integer.ValueOf(comm.Related_to_Asset__r.License_Tier__c);                        
                    }
                }
            }
            ***/
            for(Commission__c comm : commissionRecords){
                system.debug('>>>>>> 1: '+comm.Name);
                if(comm.Signing_AE__c == comm.Related_to_Quota__r.User__c){
                    system.debug('>>>>>> 2: '+comm.Name);
                    Product_Family__c productFamilies = Product_Family__c.getValues(comm.Product__r.Name); 
                    system.debug('>>>>>> 2 >>> : '+comm.Name );
                    
                    //if(comm.other_product__c == null){                        
                        system.debug('>>>>>> 3: '+comm.Name);
                        assetUnitsCount =0;
                        Product2 prod =  allProducts.get(comm.Product__c);
                        if((comm.Product__c != null) && ((w.quotaprds.Product_Name__c == prod.id) || ((productFamilies != Null) && (productFamilies.Family_Name__c == w.quotaprds.Product_Family__c)))){ 
                            system.debug('>>>>>> 4: '+comm.Name);
                            if(comm.Related_to_Asset__r.License_Tier__c != Null && Comm.Product__r.Name ==  prod.name ){
                                assetLicenseCount = assetLicenseCount+Integer.ValueOf(comm.Related_to_Asset__r.License_Tier__c);                        
                            }
                        }
                        //Product_Family__c productFamilies = Product_Family__c.getInstance(w.quotaprds.Product_Family__c);
                        system.debug('productFamilies :'+productFamilies);
                        system.debug('productFamilies :'+w.quotaprds.Product_Family__c);
                        for(string s : ProductNames){   
                            if(s != Null && prod != null && s == prod.name){
                                assetUnitsCount = assetUnitsCount+1;
                            }            
                        }   
                        system.debug('qp 1:'+allProductsTemp1 );  
                        system.debug('>>>>>> 1 222: '+comm.Name);                    
                        if(allProductsTemp1 != Null && prod != null){
                            Quota_Product__c qp = allProductsTemp1.get(prod.id);                   
                            system.debug('qp 2:'+allProductsTemp1 );                      
                            system.debug('>>>>>> 1 333: '+comm.Name);
                            if(qp == Null){
                                if(w.quotaprds.Product_Name__c != Null && w.quotaprds.Product_Family__c != Null){ 
                                        
                                   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Qualifier should be set for either a Product or a Product Family, not both. Please review your entry and try again.'));
                                } 
                                if((w.quotaprds.Product_Family__c != Null && (!mapString1.isEmpty() && mapString1.containsKey(w.quotaprds.Product_Family__c))) && w.quotaprds.id==null){ 
                                        
                                   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'This Product family already selected please select another one.'));
                                } 
                                system.debug('qp 3:'+qp);
                                if((w.quotaprds.Product_Name__c == Prod.Id) || ((productFamilies != Null ) && productFamilies.Family_Name__c == w.quotaprds.Product_Family__c)){
                                    // w.quotaprds.Sales_Achivement__c = 0; w.quotaprds.License_Achivement__c = 0; w.quotaprds.Unit_Achivement__c = 0;
                                    if(comm.Product__r.Name == Prod.Name){
                                        if(comm.Total_Commissionable_Amount__c != Null){   
                                            w.quotaprds.Sales_Achivement__c = w.quotaprds.Sales_Achivement__c+comm.Total_Commissionable_Amount__c;                                                                  
                                        }                                         
                                    }                        
                                    if(comm.Product__r.Name != Null && comm.Product__r.Name == Prod.Name){                            
                                        w.quotaprds.Unit_Achivement__c = assetUnitsCount;                            
                                    }
                                    if(comm.Product__r.Name != Null && comm.Product__r.Name == Prod.Name){                            
                                        w.quotaprds.License_Achivement__c = assetLicenseCount ;                            
                                    }    
                                    if(w.quotaprds.Sales_Achivement__c != 0 && w.quotaprds.Sales__c !=0){
                                        if(w.quotaprds.Sales_Achivement__c >= w.quotaprds.Sales__c){
                                            w.quotaprds.Target__c = TRUE;
                                        }
                                        if(w.quotaprds.Sales_Achivement__c < w.quotaprds.Sales__c){
                                            w.quotaprds.Target__c = FALSE;
                                        }
                                    }                       
                                    if(w.quotaprds.Unit_Achivement__c!= 0 && w.quotaprds.Unit__c!=0){
                                        if(w.quotaprds.Unit_Achivement__c >= w.quotaprds.Unit__c){
                                            w.quotaprds.Target__c = TRUE;
                                        }
                                        if(w.quotaprds.Unit_Achivement__c < w.quotaprds.Unit__c){
                                            w.quotaprds.Target__c = FALSE;
                                        }
                                    }                              
                                    if(w.quotaprds.License_Achivement__c != 0 && w.quotaprds.License__c!=0){
                                        if(w.quotaprds.License_Achivement__c >= w.quotaprds.License__c){
                                            w.quotaprds.Target__c = TRUE;
                                        }
                                        if(w.quotaprds.License_Achivement__c < w.quotaprds.License__c){
                                            w.quotaprds.Target__c = FALSE;
                                        }                          
                                    } 
                                    
                                   // w.quotaprds.Product_Name__c  = comm.Product__c;                        
                                }
                            }
                           
                                system.debug('qp 4:'+allProductsTemp1 );                      
                        
                                if(qp != Null){ 
                                    system.debug('qp 5:'+qp);                           
                                    if(((w.quotaprds.Product_Name__c != Null && w.quotaprds.Product_Name__c == Prod.Id) || (w.quotaprds.Product_Family__c != Null && productFamilies != Null && productFamilies.Family_Name__c == w.quotaprds.Product_Family__c)) && w.quotaprds.Name != Null){
                                        //w.quotaprds.Sales_Achivement__c = 0; w.quotaprds.License_Achivement__c = 0; w.quotaprds.Unit_Achivement__c = 0;
                                        system.debug('qp 3:'+qp);
                                        if(comm.Product__r.Name == Prod.Name){
                                            if(comm.Total_Commissionable_Amount__c != Null){   
                                                system.debug('qp 3111:'+w.quotaprds.Sales_Achivement__c);
                                                w.quotaprds.Sales_Achivement__c = w.quotaprds.Sales_Achivement__c+comm.Total_Commissionable_Amount__c;                                                                  
                                                system.debug('qp 3111:'+w.quotaprds.id+'comm :'+comm.Name);
                                                system.debug('qp 3111:'+w.quotaprds.Sales_Achivement__c);
                                                
                                            }                                         
                                        }                        
                                        if(comm.Product__r.Name != Null && comm.Product__r.Name == Prod.Name){                            
                                            w.quotaprds.Unit_Achivement__c = assetUnitsCount;                            
                                        }
                                        if(comm.Product__r.Name != Null && comm.Product__r.Name == Prod.Name){                            
                                            w.quotaprds.License_Achivement__c = assetLicenseCount ;                            
                                        }    
                                        if(w.quotaprds.Sales_Achivement__c != 0 && w.quotaprds.Sales__c !=0){
                                            if(w.quotaprds.Sales_Achivement__c >= w.quotaprds.Sales__c){
                                                w.quotaprds.Target__c = TRUE;
                                            }
                                            if(w.quotaprds.Sales_Achivement__c < w.quotaprds.Sales__c){
                                                w.quotaprds.Target__c = FALSE;
                                            }
                                        }                       
                                        if(w.quotaprds.Unit_Achivement__c!= 0 && w.quotaprds.Unit__c!=0){
                                            if(w.quotaprds.Unit_Achivement__c >= w.quotaprds.Unit__c){
                                                w.quotaprds.Target__c = TRUE;
                                            }
                                            if(w.quotaprds.Unit_Achivement__c < w.quotaprds.Unit__c){
                                                w.quotaprds.Target__c = FALSE;
                                            }
                                        }                              
                                        if(w.quotaprds.License_Achivement__c != 0 && w.quotaprds.License__c!=0){
                                            if(w.quotaprds.License_Achivement__c >= w.quotaprds.License__c){
                                                w.quotaprds.Target__c = TRUE;
                                            }
                                            if(w.quotaprds.License_Achivement__c < w.quotaprds.License__c){
                                                w.quotaprds.Target__c = FALSE;
                                            }                          
                                        }                            
                                    }
                                    
                                        if(((w.quotaprds.Product_Name__c == qp.Product_Name__c) || ((w.quotaprds.Product_Family__c !=Null) && w.quotaprds.Product_Family__c == qp.Product_Family__c)) && w.quotaprds.id== Null){                            
                                            w.quotaprds.Product_Name__c.addError('This Product already selected please select another one.');                           
                                        }
                                        
                                        if(w.quotaprds.Product_Name__c != Null && w.quotaprds.Product_Family__c != Null){ 
                                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Qualifier should be set for either a Product or a Product Family, not both. Please review your entry and try again.'));
                                        } 
                                                       
                            }
                        }
                        if((allProductsTemp1 == Null) || test.isrunningtest()) { 
                            if(Prod!=Null && ((w.quotaprds.Product_Name__c == Prod.Id) || (productFamilies.Family_Name__c == w.quotaprds.Product_Family__c))){                           
                                if(comm.Product__r.Name == Prod.Name){                               
                                    if(comm.Total_Commissionable_Amount__c != Null){                                  
                                        w.quotaprds.Sales_Achivement__c = w.quotaprds.Sales_Achivement__c+comm.Total_Commissionable_Amount__c;                                
                                    }                                         
                                }                        
                                if(comm.Product__r.Name != Null && comm.Product__r.Name == Prod.Name){                            
                                    w.quotaprds.Unit_Achivement__c = assetUnitsCount;                            
                                }
                                if(comm.Product__r.Name != Null && comm.Product__r.Name == Prod.Name){                            
                                    w.quotaprds.License_Achivement__c = assetLicenseCount ;                            
                                }
                                if(w.quotaprds.Sales_Achivement__c != 0 && w.quotaprds.Sales__c !=0){
                                    if(w.quotaprds.Sales_Achivement__c >= w.quotaprds.Sales__c){
                                        w.quotaprds.Target__c = TRUE;
                                    }
                                    if(w.quotaprds.Sales_Achivement__c < w.quotaprds.Sales__c){
                                        w.quotaprds.Target__c = FALSE;
                                    }
                                }                       
                                if(w.quotaprds.Unit_Achivement__c!= 0 && w.quotaprds.Unit__c!=0){
                                    if(w.quotaprds.Unit_Achivement__c >= w.quotaprds.Unit__c){
                                        w.quotaprds.Target__c = TRUE;
                                    }
                                    if(w.quotaprds.Unit_Achivement__c < w.quotaprds.Unit__c){
                                        w.quotaprds.Target__c = FALSE;
                                    }
                                }                              
                                if(w.quotaprds.License_Achivement__c != 0 && w.quotaprds.License__c!=0){
                                    if(w.quotaprds.License_Achivement__c >= w.quotaprds.License__c){
                                        w.quotaprds.Target__c = TRUE;
                                    }
                                    if(w.quotaprds.License_Achivement__c < w.quotaprds.License__c){
                                        w.quotaprds.Target__c = FALSE;
                                    }                          
                                } 
                                if(w.quotaprds.Product_Name__c != Null && w.quotaprds.Product_Family__c != Null){ 
                                system.debug('?????? 3:'+w.quotaprds.CreatedDate);
                                   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Qualifier should be set for either a Product or a Product Family, not both. Please review your entry and try again.'));  
                                }  
                            }
                        }
                        system.debug('qp 31112  :'+w.quotaprds.Sales_Achivement__c);
                                                
                   // }
                    system.debug('>>>>> 1:'+comm.other_product__c);
                   
                }
            }
            system.debug('qp 3111 32:'+w.quotaprds.id);
            system.debug('qp 3111 33:'+w.quotaprds.Sales_Achivement__c);
                                                
        }
      
        return null;
        
    }
   
    //Save method
    
    public PageReference save(){
        isError = false;
        //Validation rule to validate sales,units and license values,user should not enter any two values at a time
        for(wrapQuota w : wrapQuotaList){
        if(w.quotaprds.Product_Name__c != Null && w.quotaprds.Product_Family__c != Null){ 
             apexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Qualifier should be set for either a Product or a Product Family, not both. Please review your entry and try again.'));
            return null;
        } 
        if(w.quotaprds.Product_Name__c == Null && w.quotaprds.Product_Family__c == Null){
           w.quotaprds.Product_Name__c.addError('Product or Product Family is Mandatory to add Qualifier');
           return null;
        }
        if(w.quotaprds.Sales__c == Null && w.quotaprds.Unit__c == Null && w.quotaprds.License__c  == Null){
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Fatal,'Please enter Sales/Units/License any one value'));
           return null;
        }
         if((w.quotaprds.Sales__c != Null && w.quotaprds.Unit__c != Null ) || (w.quotaprds.Sales__c != Null && w.quotaprds.License__c!= Null) || (w.quotaprds.Unit__c != Null && w.quotaprds.License__c!= Null)){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Fatal,'Please enter Sales/Units/License any one value'));
                isError = true;
           }
        }
        List<Quota_Product__c> InserQuotaProduct = new List<Quota_Product__c>();
        Map<id,Quota_Product__c> InserQuotaProductMap = new Map<id,Quota_Product__c>();
        
        List<Quota__c> updateQuota = new List<Quota__c>();
        integer count = 0;
        if(isError == false){
            for(wrapQuota w : wrapQuotaList){
                w.quotaprds.Related_To_Quota__c = RecordId; 
                //for(commission__c comm : commissionRecordsTemp){
                   // Product_Family__c productFamilies = Product_Family__c.getValues(comm.Product__r.Name); 
                    //if(comm.product__c != null && productFamilies!= null && comm.product__r.Name == productFamilies.Name  && productFamilies.Family_name__c == comm.product__r.Product_Family__c){                   
                        //w.quotaprds.Product_Name__c = comm.Product__c;
                       // w.quotaprds.Product__c = comm.Product__c;
                        InserQuotaProduct.add(w.quotaprds);
                        InserQuotaProductMap.put(w.quotaprds.Id,w.quotaprds);
                        if(w.quotaprds.Target__c == true){
                            count++;
                        }
                   // }
                //}
            }
        }
         
        set<id> updatableQuotaId=new Set<Id>();
        //added the lines to skip the row lock error - Srinivas vadla - CRM-2099
        for(quota__c quota:[select id,name from Quota__c where id=:RecordId limit 1 for Update ]){
            updatableQuotaId.add(quota.id);
        }
        //updating quots with kicker and without kicker  - Srinivas vadla - CRM-2099
        if(updatableQuotaId!=null && !updatableQuotaId.isEmpty() && updatableQuotaId.contains(RecordId)){
            quota__c quota = new Quota__c();
            quota.id = RecordId;
            quota.Is_Kicker__c = InserQuotaProduct.size() == count?True:False;
            SkipQuotaTrigger.setSkipTrgTrue();
            update quota;        
        }
        //Inserting products 
        if(InserQuotaProductMap.size() > 0){
            try{
                upsert InserQuotaProductMap.Values(); 
            callfunc='<script> fun(); </script>';  
            }
            catch(Exception e){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Quota Products are loading...');
                ApexPages.addMessage(myMsg);
            }         
        } 
       /*
       //updating quots with kicker and without kicker
        if(InserQuotaProduct.size() == count){
            quota__c quota = new Quota__c();
            quota.id = RecordId;
            quota.Is_Kicker__c = TRUE;
            SkipQuotaTrigger.setSkipTrgTrue();
            update quota;                     
            //System.debug('quota 123:'+quota);
        }
        if(InserQuotaProduct.size() != count){
            quota__c quota = new Quota__c();
            quota.id = RecordId;
            quota.Is_Kicker__c = false;
            SkipQuotaTrigger.setSkipTrgTrue();   
            update quota; 
                     
            //System.debug('quota 456:'+quota);
                  
        }  */
        
        return null;
    }  
   
    //Wrapper class - it will contains all products info and selected products info
    public class wrapQuota{
        public Quota_Product__c quotaprds{get;set;}
        public boolean isSelected {get;set;}     
        public String tempValue {get;set;}
    }   
}