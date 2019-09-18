public class MassAssetUpdateController {
    public List<Asset> selectedAssets {get;set;}
    public Asset objAsset {get;set;}
    string strReturnURL;
    public MassAssetUpdateController(ApexPages.StandardSetController controller) {
        selectedAssets = controller.getSelected();
        
        strReturnURL = ApexPages.currentPage().getParameters().get('retURL');
        objAsset = new Asset();
        
    } 
    
    public pagereference updateAssets(){
        List<Asset> lstAssetUpdate = new List<Asset>();
          
        
        if(!selectedAssets.isEmpty()){

            for(Asset ast: selectedAssets){
                ast.Follow_Up_Status__c = objAsset.Follow_Up_Status__c;
                ast.Reason__c =  objAsset.Reason__c;
                ast.Reason_Details__c = objAsset.Reason_Details__c;
                ast.Comments__c  = objAsset.Comments__c ;
                
              /*   If( objAsset.Follow_Up_Status__c == 'Will Not Renew'){
                      ast.Renewal_Status__c = 'Do Not Renew';
                       
                   } */
                   

      if(objAsset.Follow_Up_Status__c == 'Will Not Renew' && ( objAsset.Reason__c == null || objAsset.Reason_Details__c == null)){
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Once the Follow Up status on Asset is set to \'Do not Renew\', Reason and Reason Details have to be populated.'));              
         
        return null;  
               
       }else{             
                lstAssetUpdate.add(ast);
                }
            } 

            if(!lstAssetUpdate.isEmpty()){
                update lstAssetUpdate;
                pagereference pr = new pagereference(strReturnURL);
                return pr;
            }
        }
 return null;       
    }
}