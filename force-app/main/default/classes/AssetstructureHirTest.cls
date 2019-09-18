@isTest
public class AssetstructureHirTest {

    //private static final 
    static testMethod void method1(){
    Integer COUNTER = 10;
     DisabledTrigger__c settings = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert settings;
   Error_Notification_Email_Settings__c emailSettings = new Error_Notification_Email_Settings__c(name='Email Addresses',    
                                                            Asset_Creation_Error_Emails__c='test@mailinator.com',View_Link__c='https://cs11.salesforce.com/02i?fcf=00BZ00000017ilI');
     insert emailSettings;   
   Account testAcc = TestDataFactory.createAccount('The Test Account', null, True);        
   
    test.startTest();
        asset a ;
    List<Asset> theTestAssets = new List<Asset>();
    for(Integer index = 0; index < COUNTER; index++) {
        theTestAssets.add(new Asset(
         Name = 'Test Asset - ' + index,
         AccountId = testAcc.Id,
         Price = 10,       
         Auto_Renewal__c = 'Yes',
         Asset_Type__c='Parent',
         Renewal_Start_Date__c=system.today(),
         End_Date__c =  system.today().addDays(-10),
         Status = 'Active'
        ));
    }
    try{
      insert theTestAssets;
         a = new asset(Name = 'Test Asset -inde ',
         AccountId = testAcc.Id,
         Price = 10,       
         Auto_Renewal__c = 'Yes',
         Asset_Type__c='Parent',
         parent_Asset__C= theTestAssets[0].id,                  
         Renewal_Start_Date__c=system.today(),
         End_Date__c =  system.today().addDays(-10),
         Status = 'Active');
        insert a;
      List<asset> lstAssete = New List<asset>();
        for(Asset ast: theTestAssets){
          ast.Fulfillment_Status__c = 'Pending Fulfillment';
          ast.Status = 'Expired';
          ast.Line_Type__c = 'Cancel';
        }
        if(lstAssete.size()>0){
         update lstAssete;
        }
           
      }catch(exception e){}
        list<string> strs =new list<string>{'1','2','3','4'};
        list<string> nnl = new list<string>();   
        apexpages.currentPage().getParameters().put('id',a.id);
        AssetStructureHir controller = new AssetStructureHir();
       list<AssetStructureHir.ObjectStructureMap> maps = controller.getObjectStructure();
        controller.setcurrentId(string.valueof(theTestAssets[0].id));
       list<boolean> b = controller.setlevelFlag(strs,'4');
        boolean lnode = controller.isLastNode(strs);
        list<boolean> bsetcloase = controller.setcloseFlag(strs, nnl, 'node1');
        Test.stopTest();
    }
}