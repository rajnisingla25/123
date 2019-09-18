@isTest
public class MultiselectcontrollerTest {
    static testMethod void  testMultiSelectOptions(){ 
    test.startTest();         
        string value1 = 'True';
        list<SelectOption> options =new list<SelectOption>();          
        MultiselectController m = new multiselectController();
        m.setOptions(options,value1);  
        list<SelectOption> left = m.leftOptions;      
        list<SelectOption> rightt = m.rightOptions;
       try{
        m.leftOptionsHidden = value1;        
        }catch(Exception e){}
        try{
        m.rightOptionsHidden  = value1;
        }catch(Exception e){}
        test.stopTest();

    }
}