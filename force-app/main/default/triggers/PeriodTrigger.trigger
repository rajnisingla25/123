trigger PeriodTrigger on Period__c (before insert,before update){    
    for(Period__c Prd : trigger.New){
        Integer MonthValue =  Prd.Start_Date__c.Month();   
        Integer YearValue = Prd.Start_Date__c.Year(); 
        String Quater = '' ;
        if((MonthValue == 1) || (MonthValue == 2) || (MonthValue == 3)){
            Quater = 'Q1';
        }
        if(MonthValue == 04 || MonthValue == 05 || MonthValue == 06){
            Quater = 'Q2';    
        }
        if(MonthValue == 07 || MonthValue == 08 || MonthValue == 09){
            Quater = 'Q3';
        }
        if(MonthValue == 10 || MonthValue == 11 || MonthValue == 12){
            Quater = 'Q4';
        }        
        Prd.Current_Quater__c = Quater;
    }
}