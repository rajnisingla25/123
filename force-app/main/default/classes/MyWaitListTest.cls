public with sharing class MyWaitListTest {
	    public List<String> Field1 {get; set;}
    public List<String> Field2 {get; set;}
    public List<String> Field3 {get; set;}
    public List<String> Field4 {get; set;}
    public List<String> Field5 {get; set;}
    public List<String> Field6 {get; set;}
    public List<String> Field7 {get; set;}
    public List<String> Field8 {get; set;}
    public List<String> Field9 {get; set;}
    public List<String> Field10 {get; set;}
    public List<String> Field11 {get; set;}
    public List<String> Field12 {get; set;}
    public List<String> Field13 {get; set;}
    public List<String> Field14 {get; set;}
    public List<String> Field15 {get; set;}
    public List<String> Field16 {get; set;}
    public List<String> Field17 {get; set;}
    public List<String> Field18 {get; set;}
    public List<String> Field19 {get; set;}
    public List<String> Field20 {get; set;}                    
    public String searchstring {get; set;}
  
    public MyWaitListTest() {
        this.Field1 = new List<String>{'Testnote1', 'Testnote2', 'Testnote3', 'Testnote4', 'Testnote5'};
        this.Field2 = new List<String>{'1-2G75-63', '1-44DF-549', '1-3PLI-15', '1-3PLI-16', '1-93L-1'};
        this.Field3 = new List<String>{'Bruce Sayre', 'Mark Wheelis', 'John Ellis', 'Kelli Lovingfoss', 'Theresa Graham'};
        this.Field4 = new List<String>{'(334) 590-3620', '(361) 935-4789', '(404) 408-7318', '(317) 570-3800', '(301) 980-9437'};
        this.Field5 = new List<String>{'Unassigned', 'Unassigned', 'Unassigned', 'Unassigned', 'Unassigned'};
        this.Field6 = new List<String>{'ACOHEN', 'MBAM', 'ACOHEN', 'MASR', 'MBAM'};
        this.Field7 = new List<String>{'5000', '1500', '4000', '8000', '1200'};
        this.Field8 = new List<String>{'Hot', 'Warm', 'Hot', 'Hot', 'Warm'};
        this.Field9 = new List<String>{'4/16/2015', '4/15/2015', '4/16/2015', '4/16/2015', '4/15/2015'};
        this.Field10 = new List<String>{'', 'Waitlisted', 'Not Intrested', 'Waitlisted', 'Not Intrested'};
        this.Field11 = new List<String>{'4/16/2015', '4/15/2015', '4/16/2015', '4/16/2015', '4/15/2015'};
        this.Field12 = new List<String>{'63127', '37212', '94539', '94536', '95113'};
        this.Field13 = new List<String>{'half', 'full', 'half', 'half', 'full'};
        this.Field14 = new List<String>{'MO', 'TN', 'CA', 'CA', 'CA'};
        this.Field15 = new List<String>{'Saint Louis', 'Nashvile', 'Fremont', 'Fremont', 'San Jose'};
        this.Field16 = new List<String>{'SaintLouis', 'Nashvile', 'Alamada', 'Alamada', 'Santaclara'};
        this.Field17 = new List<String>{'0', '0', '0', '0', '0'};               
        this.Field18 = new List<String>{'0', '0', '0', '0', '0'};
        this.Field19 = new List<String>{'1', '0', '0', '2', '0'};
        this.Field20 = new List<String>{'0', '2', '4', '0', '2'};
        
       String[] searchStr1 = new String[]{'AE', 'AccountId','Market','City','County','State' };
        this.searchOpt1 = new SelectOption[]{};
        for (String c: searchStr1) {
            this.searchOpt1.add(new SelectOption(c,c));
        }
        String[] searchStr2 = new String[]{'All','InventoryAvailable','Pre Auth','Pre Sale','Hot','Warm','Cool' };
        this.searchOpt2 = new SelectOption[]{};
        for (String c: searchStr2) {
            this.searchOpt2.add(new SelectOption(c,c));
        }        
    }

    public List<Integer> getIndexes() {
        List<Integer> indexes = new List<Integer>();
        for (Integer i = 0; i < this.Field1.size(); i++) indexes.add(i);
        return indexes;
    }

   public SelectOption[] searchOpt1 {
        public get;
        public set;
    }
    public SelectOption[] searchOpt2 {
        public get;
        public set;
    }    
	
	
	

}