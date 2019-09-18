/*
Apex class :AccountStatement
Purpose :- AccountStatement class is used to develop account statment
CRM - OTC-208
Author :- Sonu Sharma, Move Inc
*/
Public class SelectAccountStatement {

    Public string StartDate {
        get;
        set;
    }
    Public string Previous0 {
        get;
        set;
    }
    Public string Previous1 {
        get;
        set;
    }
    Public string Previous2 {
        get;
        set;
    }
    Public string Previous3 {
        get;
        set;
    }
    Public string Previous4 {
        get;
        set;
    }
    Public string Previous5 {
        get;
        set;
    }
    Public string Previous6 {
        get;
        set;
    }
    
    Public Boolean display0{get;set;}
    Public Boolean display1{get;set;}
    Public Boolean display2{get;set;}
    Public Boolean display3{get;set;}
    Public Boolean display4{get;set;}
    Public Boolean display5{get;set;}
    Public Boolean display6{get;set;}
    
    String AccountId = '';
    List<OrderItem> lstOrderitem{get;set;}
    
    Public SelectAccountStatement(){
    display0 = true;
    display1 = true;
    display2 = true;
    display3 = true;
    display4 = true;
    display5 = true;
    display6 = true;
    
    Accountid = ApexPages.currentPage().getParameters().get('id');
    lstOrderitem = [Select id,Start_date__c,End_Date__c from OrderItem limit 1];
    if(Test.isRunningTest()){lstOrderitem = new List<OrderItem>();
    OrderItem oitem = new OrderItem();
    lstOrderitem.add(oitem);
    }
    lstOrderitem[0].Start_date__c = System.today().toStartOfMonth();
    lstOrderitem[0].End_date__c = System.today().AddMonths(1).toStartOfMonth().AddDays(-1);
    Integer year = System.today().Year();
    Previous0 = MonthString(System.today().month()+'');
    Previous1 = MonthString(System.today().AddMonths(-1).month()+'');
    Previous2 = MonthString(System.today().AddMonths(-2).month()+'');
    if(System.today().AddMonths(-2).month()<1){display2=false;}
    Previous3 = MonthString(System.today().AddMonths(-3).month()+'');
    if(System.today().AddMonths(-3).month()<1){display3=false;}
    Previous4 = MonthString(System.today().AddMonths(-4).month()+'');
    if(System.today().AddMonths(-4).month()<1){display4=false;}
    Previous5 = MonthString(System.today().AddMonths(-5).month()+'');
    if(System.today().AddMonths(-5).month()<1){display5=false;}
    Previous6 = MonthString(System.today().AddMonths(-6).month()+'');
    if(System.today().AddMonths(-6).month()<1){display6=false;}
    }
    Public List<OrderItem> getlstOrderitem(){
    Return lstOrderitem;
    }
    // CRM-3254: Updated the page URL to redirect to AccountStatement instead of AccountStatementNew.
    Public PageReference RedirectToAccountStatementPrevious0(){
    String StartDate = System.today().AddMonths(0).toStartOfMonth()+'';
    String EndDate = System.today().AddMonths(1).toStartOfMonth().AddDays(-1)+'';
    PageReference pr = new PageReference('/apex/AccountStatement?id='+Accountid+'&startdate='+StartDate+'&enddate='+EndDate);
    pr.setRedirect(true);
    return pr;
    }
    
    Public PageReference RedirectToAccountStatementPrevious1(){
    String StartDate = System.today().AddMonths(-1).toStartOfMonth()+'';
    String EndDate = System.today().AddMonths(1-1).toStartOfMonth().AddDays(-1)+'';
    PageReference pr = new PageReference('/apex/AccountStatement?id='+Accountid+'&startdate='+StartDate+'&enddate='+EndDate);
    pr.setRedirect(true);
    return pr;
    }
    Public PageReference RedirectToAccountStatementPrevious2(){
    String StartDate = System.today().AddMonths(-2).toStartOfMonth()+'';
    String EndDate = System.today().AddMonths(1-2).toStartOfMonth().AddDays(-1)+'';
    PageReference pr = new PageReference('/apex/AccountStatement?id='+Accountid+'&startdate='+StartDate+'&enddate='+EndDate);
    pr.setRedirect(true);
    return pr;
    }
    Public PageReference RedirectToAccountStatementPrevious3(){
    String StartDate = System.today().AddMonths(-3).toStartOfMonth()+'';
    String EndDate = System.today().AddMonths(1-3).toStartOfMonth().AddDays(-1)+'';
    PageReference pr = new PageReference('/apex/AccountStatement?id='+Accountid+'&startdate='+StartDate+'&enddate='+EndDate);
    pr.setRedirect(true);
    return pr;
    }
    Public PageReference RedirectToAccountStatementPrevious4(){
    String StartDate = System.today().AddMonths(-4).toStartOfMonth()+'';
    String EndDate = System.today().AddMonths(1-4).toStartOfMonth().AddDays(-1)+'';
    PageReference pr = new PageReference('/apex/AccountStatement?id='+Accountid+'&startdate='+StartDate+'&enddate='+EndDate);
    pr.setRedirect(true);
    return pr;
    }
    Public PageReference RedirectToAccountStatementPrevious5(){
    String StartDate = System.today().AddMonths(-5).toStartOfMonth()+'';
    String EndDate = System.today().AddMonths(1-5).toStartOfMonth().AddDays(-1)+'';
    PageReference pr = new PageReference('/apex/AccountStatement?id='+Accountid+'&startdate='+StartDate+'&enddate='+EndDate);
    pr.setRedirect(true);
    return pr;
    }
    Public PageReference RedirectToAccountStatementPrevious6(){
    String StartDate = System.today().AddMonths(-6).toStartOfMonth()+'';
    String EndDate = System.today().AddMonths(1-6).toStartOfMonth().AddDays(-1)+'';
    PageReference pr = new PageReference('/apex/AccountStatement?id='+Accountid+'&startdate='+StartDate+'&enddate='+EndDate);
    pr.setRedirect(true);
    return pr;
    }
    /**/
    
    Public PageReference RedirectToAccountStatement(){
    //date firstDate = System.today().toStartOfMonth();
    String StartDate = lstOrderitem[0].Start_date__c+'';
    String EndDate = lstOrderitem[0].End_date__c+'';
    PageReference pr = new PageReference('/apex/AccountStatement?id='+Accountid+'&startdate='+StartDate+'&enddate='+EndDate);
    pr.setRedirect(true);
    return pr;
    }
    
    Public String MonthString(String monthnum){
    Map<String,String> mapMonths = new Map<String,String>();
    mapMonths.put('1','January');
    mapMonths.put('2','February');
    mapMonths.put('3','March');
    mapMonths.put('4','April');
    mapMonths.put('5','May');
    mapMonths.put('6','June');
    mapMonths.put('7','July');
    mapMonths.put('8','August');
    mapMonths.put('9','September');
    mapMonths.put('10','October');
    mapMonths.put('11','November');
    mapMonths.put('12','December');
    //mapMonths.put('1','August');
    String retMonthText = mapMonths.get(monthnum);
    return retMonthText;
    }
}