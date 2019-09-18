public with sharing class AcctExtension 
{
    //http://qa.geo.svc.move.com/GeoWcfService/State.svc/Cities/ca?app=test&format=json

    private final Account acct;    
    public String ProductselectedVal{get;set;}
    public String StatusselectedVal{get;set;}
    public String MarketTypeselectedVal{get;set;}
    public String DegreeselectedVal{get;set;}           
    public String LeadRoutingselectedVal{get;set;}    
    public String PostalCodeselectedVal{get;set;}    
               
    public String Quantity{get;set;}                   
    public String marketTextArea{get;set;} 
    public goewcfService geo = new goewcfService();
    public list<SelectOption> countyOptions {get;set;}
    public list<SelectOption> cityOptions {get;set;}    
    
    public boolean stateFlag {get;set;}
    public boolean cityFlag {get;set;}
    public boolean countyFlag {get;set;}
    
    public string stateSelected {get;set;}
    public string CountySelected {get;set;}
    public string CitySelected {get;set;}    
    
              
    public boolean pbTable {get;set;}            
    public list<marketWrapper> marketList {get;set;}
            
    public string stateURL = 'http://qa.geo.svc.move.com/GeoWcfService/Country.svc/States/?app=test&format=json';
    public string countyURL = '';
    public string cityURL = '';
    
    public list<SelectOption> selectedcountyOptions {get;set;}   
    public list<SelectOption> selectedcityOptions {get;set;}     
    
    

            
    public AcctExtension (ApexPages.StandardController stdController) 
    {
            this.acct = (Account)stdController.getRecord();
            pbTable = false;
            marketList =  new list<marketWrapper>();
            countyOptions =  new List<SelectOption>();
            cityOptions  =  new List<SelectOption>();
            selectedcountyOptions =  new List<SelectOption>();
            selectedcityOptions   =  new List<SelectOption>(); 
            stateFlag   = false;
            cityFlag    = false;
            countyFlag  = false; 
            Quantity = '1';             
            LeadRoutingselectedVal = 'Any';                     
    }
   
    public List<SelectOption> getStateOptions()
    {                            
            return addNone(geo.JSONtoOptions(stateURL));
    }
   
    public pageReference queryDependecies()
    {
        if(MarketTypeselectedVal != null && MarketTypeselectedVal != '')
        {
            if(MarketTypeselectedVal  == 'StateCity')
                queryCitys();
            if(MarketTypeselectedVal  == 'StateCounty')
                queryCountys();
            
        }
        
        return null;
    }
    public pageReference queryCountys()
    {
        system.debug('******stateSelected****'+stateSelected);
        countyOptions = new List<SelectOption>();
        if(stateSelected  != null && stateSelected != '')
        {
            countyURL  = 'http://qa.geo.svc.move.com/GeoWcfService/State.svc/Counties/'+stateSelected+'?app=test&format=json';            
            countyOptions.addAll(geo.JSONtoOptions(countyURL));   
            if(countyOptions.size() > 0)
              countyFlag  = true;          
        }
        else
        {
             cityFlag    = false;
             countyFlag  = false;    
        }
        return null;
    }
    
       
    public pageReference queryCitys()
    {
        cityOptions  = new List<SelectOption>();
        if(stateSelected  != null && stateSelected  != '')
        {
            string stateAbbURL = 'http://qa.geo.svc.move.com/GeoWcfService/State.svc/StateAbbreviation/'+stateSelected+'?app=test&format=JSON';
            string stateAbb   = geo.JSONStateAbbrevation(stateAbbURL);
            //cityURL  = 'http://qa.geo.svc.move.com/GeoWcfService/County.svc/CityNamesWithinCounty/'+stateAbb+'/'+CountySelected+'?app=test&format=JSON';
            cityURL  = 'http://qa.geo.svc.move.com/GeoWcfService/State.svc/Cities/'+stateAbb+'?app=test&format=json';            
            cityOptions.addAll(geo.JSONtoOptions(cityURL));   
            cityFlag    = true;            
        }
        else
        {
             cityFlag    = false;
             countyFlag  = false; 
        }
        return null;
    }
    
    public pageReference  checkMarketType()
    {
        if(MarketTypeselectedVal != 'PostalCode')
        {
        
            stateFlag   = true;   
            stateSelected = ''; 
            selectedcountyOptions = new list<SelectOption>();
            selectedcityOptions   = new list<SelectOption>();
            marketTextArea = '';
            marketList =  new list<marketWrapper>();
            if(MarketTypeselectedVal == 'StateCity')
            {
            if(selectedcityOptions.size() > 0)
                 cityFlag    = true;
             countyFlag  = false;             
            }
            if(MarketTypeselectedVal == 'StateCounty')
            {
             cityFlag    = false;
             if(selectedcountyOptions.size() > 0)
             countyFlag  = true;             
            }            
            
                            
        }
        else
        {
            stateFlag   = false;
            cityFlag    = false;
            countyFlag  = false;                         
            stateSelected = ''; 
            selectedcountyOptions = new list<SelectOption>();
            selectedcityOptions   = new list<SelectOption>();
            marketTextArea = '';
            marketList =  new list<marketWrapper>();            
        }
        return null;
    }
                
    public List<SelectOption> getProductOptions()
    {
            List<SelectOption> optns = new List<Selectoption>();                        
             optns.add(new selectOption('Product1','Product1'));
             optns.add(new selectOption('Product2','Product2'));
             optns.add(new selectOption('Product3','Product3'));                  
                        
            return optns;
    }

    public List<SelectOption> getPostalCodeOptions()
    {
            List<SelectOption> optns = new List<Selectoption>();                        
             optns.add(new selectOption('PostalCode1','PostalCode1'));
             optns.add(new selectOption('PostalCode2','PostalCode2'));
             optns.add(new selectOption('PostalCode3','PostalCode3'));                  
                        
            return optns;
    }
    
        
    public List<SelectOption> getStatusOptions()
    {
            List<SelectOption> optns = new List<Selectoption>();                        
             optns.add(new selectOption('Hot','Hot'));
             optns.add(new selectOption('Warm','Warm'));                
                        
            return optns;
    }
    
    public List<SelectOption> getMarketTypetOptions()
    {
            List<SelectOption> optns = new List<Selectoption>();      
             optns.add(new SelectOption('','-None-'));                  
             optns.add(new selectOption('PostalCode','Postal Code'));                          
             optns.add(new selectOption('StateCity','State City'));
             optns.add(new selectOption('StateCounty','State County'));
                    
                        
            return optns;
    }
    
    public List<SelectOption> getDegreeOptions()
    {
            List<SelectOption> optns = new List<Selectoption>();                        
             optns.add(new selectOption('Hot','Hot'));
             optns.add(new selectOption('Warm','Warm'));
                        
            return optns;
    }
    
    
    public List<SelectOption> getLeadRoutingOptions()
    {
            List<SelectOption> optns = new List<Selectoption>();                        
             optns.add(new selectOption('Flex','Flex'));
             optns.add(new selectOption('Fast','Fast'));
             optns.add(new selectOption('Any','Any'));         
                        
            return optns;
    }
    
    public pageReference callapex()
    {
        return null;
    }
    
    public pageReference submit()
    {
        return null;
    }
    
    public pageReference cancel()
    {
        return new pageReference('/'+this.acct.ID);
    }
        
        
    
    public List<SelectOption> addNone(list<selectOption> opt)
    {
        opt.add(new SelectOption('','--None--'));
        opt.sort();
        return opt;
    }
    
        
    public pageReference GenerateTable()
    {
        string selectedString = '';
        list<SelectOption> temp = new list<SelectOption>();                         
        if(selectedcountyOptions.size() > 0)        
            temp.addAll(selectedcountyOptions); 
        if(selectedcityOptions.size() > 0)                
            temp.addAll(selectedcityOptions);     
        
        if(temp.size() > 0)
        {
            Boolean first = true;            
            for ( SelectOption so : temp) {
            if (!first) {
                selectedString  += ', ';
            }
            selectedString  += so.getValue();
            first = false;
            }
        }
        if(MarketTypeselectedVal != 'PostalCode')
            marketTextArea  = selectedString;
        marketList =  new list<marketWrapper>();
        
        if(marketTextArea != '')
        {  
                                                  
              list<string> valuesEntered = marketTextArea.split(',');             
              for(string oString : valuesEntered )
              {
                pbTable = true;                
                marketList.add(new marketWrapper(ProductselectedVal,
                                                 StatusselectedVal,
                                                 MarketTypeselectedVal,
                                                 DegreeselectedVal,
                                                 LeadRoutingselectedVal,
                                                 Quantity,
                                                 oString
                                                 ));
                      
              }                              
        }
        return null;
    }            
        
   // Wrapper class    
   public class marketWrapper 
   {
        public String Product { get; set; }
        public String Status { get; set; }
        public String MarketType { get; set; }                        
        public String Degree { get; set; }                                
        public String LeadRouting { get; set; }                                        
        public String Quantity { get; set; }                                                
        public String marketText { get; set; }          
        
        public marketWrapper(String pr, String st, String ma,String de,string le,string qu,string mr) 
        {
            this.Product = pr;
            this.Status = st;       
            this.MarketType = ma;   
            this.Degree = de;   
            this.LeadRouting = le; 
            this.Quantity = qu;   
            this.marketText = mr;                          
                                                 
        }
    }                               
    
}