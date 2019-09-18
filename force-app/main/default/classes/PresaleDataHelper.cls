global class PresaleDataHelper {
   	 @invocablemethod(label='Get Available Inventory' description='Stores in Presale Object')
    public static void splitString(List<BigMachines__Quote_Product__c> availableInventory){
        for(BigMachines__Quote_Product__c s : availableInventory){
            	String strReplace = s.Available_Presale_Inventory__c;
            	strReplace = strReplace.replace('$','!').replace('$','!');
            	System.debug(strReplace);
    			List<String>  availableInventoryRecords= strReplace.split('!!');
    			System.debug(availableInventoryRecords);
    			List<Presale_Available_Inventory__c> tasks = new List<Presale_Available_Inventory__c>();
        		for(String r : availableInventoryRecords){
                    List<String> availableInventoryFields= r.split('@@');
                    System.debug(availableInventoryFields);
                    Presale_Available_Inventory__c f = new Presale_Available_Inventory__c();
                    f.Presale_Quantity__c = Decimal.valueOf(availableInventoryFields.get(0));
                    String temp = availableInventoryFields.get(1).replace('/',' ');
                    f.Availability_Date__c = PresaleDataHelper.getConvertDateTime(temp);
                    /*System.debug(temp);
                    temp = temp.replace('T',' ');
                    System.debug(temp);
                    temp = temp.substring(0, 18);
                    System.debug(temp);
                    Date tempdt = Date.parse(temp.DateValMask);
                    String myDate =  tempdt.DateConvert("mm/dd/yyyy","yyyy-mm-dd",tempdt);
                        //tempdt.format(DateAdd("d", 2, DateAdd("d", -(weekday(FieldAt("tempdt"))), FieldAt("tempdt")), "yyyy-mm-dd hh:mm:ss"); // formats the date
					system.debug('myDate='+myDate);
                    
                    //System.debug(temp);*/
                    
                    f.Availability_Date__c = f.Availability_Date__c.date();
                    System.debug(f.Availability_Date__c);
                    f.Inventory_Transaction_Id__c = availableInventoryFields.get(2);
                    f.Quote_Product__c = s.id;
                    String ContractTerm = s.Contract_Term__c;
                    if(ContractTerm==null){
                        ContractTerm='6';
                    }
                    f.End_date__c = f.Availability_Date__c.date();
         			f.End_date__c = f.End_date__c.AddMonths(Integer.valueof(ContractTerm)).AddDays(-1); 
                    tasks.add(f);
                }
     	if (tasks.size()>0)
            upsert tasks;
  

        
    }
    } 
    public static DateTime getConvertDateTime(string strDT)
    {
            
            Map<string,integer> MapMonthList = new Map<string,integer>();
            MapMonthList.put('January',1);
            MapMonthList.put('February',2);
            MapMonthList.put('March',3);
            MapMonthList.put('April',4);
            MapMonthList.put('May',5);
            MapMonthList.put('June',6);
            MapMonthList.put('July',7);
            MapMonthList.put('August',8);
            MapMonthList.put('September',9);
            MapMonthList.put('October',10);
            MapMonthList.put('November',11);
            MapMonthList.put('December',12);
            
            String[] strDTDivided = strDT.split(' ');
            
            string month = strDTDivided.get(0);
            string day = strDTDivided.get(1);
            string year = strDTDivided.get(2);
            
            string hour = strDTDivided.get(3).split(':').get(0);
            string minute = strDTDivided.get(3).split(':').get(1);
            string second = '00';
            
            if (strDTDivided.get(4) == 'PM')
            {
            hour = String.ValueOf(Integer.ValueOf(hour) + 12);
            }
            string stringDate = year + '-' + month + '-' + day + ' ' + hour + ':' + minute + ':' + second;
            
            return datetime.valueOf(stringDate);
            
            }
 

}