public class AssetAllBrokerAssetList2Con {
    Public String Accid{get;set;}
    Public String PageNumber{get;set;}
    Public String AccName{get;set;}
    Public List<Asset> lstAllBrokerAssets = new List<Asset>();
     List<Asset> lstAllBrokerAssets0 = new List<Asset>();
     List<Asset> lstAllBrokerAssets1 = new List<Asset>();
     List<Asset> lstAllBrokerAssets2 = new List<Asset>();
     List<Asset> lstAllBrokerAssets3 = new List<Asset>();
    Public  Integer ii;
     List<Asset> lstAllBrokerAssets4 = new List<Asset>();
     List<Asset> lstAllBrokerAssets5 = new List<Asset>();
     List<Asset> lstAllBrokerAssets6 = new List<Asset>();
     List<Asset> lstAllBrokerAssets7 = new List<Asset>();
     List<Asset> lstAllBrokerAssets8 = new List<Asset>();
     List<Asset> lstAllBrokerAssets9 = new List<Asset>();
     List<Asset> lstAllBrokerAssets10 = new List<Asset>();
     List<Asset> lstAllBrokerAssets11 = new List<Asset>();
     List<Asset> lstAllBrokerAssets12 = new List<Asset>();
     List<Asset> lstAllBrokerAssets13 = new List<Asset>();
     List<Asset> lstAllBrokerAssets14 = new List<Asset>();
     List<Asset> lstAllBrokerAssets15 = new List<Asset>();
     List<Asset> lstAllBrokerAssets16 = new List<Asset>();
     List<Asset> lstAllBrokerAssets17 = new List<Asset>();

    Public List<Asset> lstAllPageBrokerAssets = new List<Asset>();
    Public Map<String,List<Asset>> MapAllPageBrokerAssets = new Map<String,List<Asset>>();
    Public String baseurl{get;set;}
    Public Set<String> setStatus = new Set<String>{'Active','Cancelled','Converted','Pending Fulfillment'};
    public List<Asset> getAssets(){
                if(PageNumber=='0' || PageNumber==null){
                lstAllPageBrokerAssets = lstAllBrokerAssets0;
                } 
                 if(PageNumber=='1'){lstAllPageBrokerAssets = lstAllBrokerAssets1;
                } 
                 if(PageNumber=='2'){lstAllPageBrokerAssets = lstAllBrokerAssets2;
                } 
                 if(PageNumber=='3'){lstAllPageBrokerAssets = lstAllBrokerAssets3;
                } 
                 if(PageNumber=='4'){lstAllPageBrokerAssets = lstAllBrokerAssets4;
                } 
                 if(PageNumber=='5'){lstAllPageBrokerAssets = lstAllBrokerAssets5;
                }
                 if(PageNumber=='6'){lstAllPageBrokerAssets = lstAllBrokerAssets6;
                }
                 if(PageNumber=='7'){lstAllPageBrokerAssets = lstAllBrokerAssets7;
                }
                 if(PageNumber=='8'){lstAllPageBrokerAssets = lstAllBrokerAssets8;
                }
                 if(PageNumber=='9'){lstAllPageBrokerAssets = lstAllBrokerAssets9;
                }
                 if(PageNumber=='10'){lstAllPageBrokerAssets = lstAllBrokerAssets10;
                }
                 if(PageNumber=='11'){lstAllPageBrokerAssets = lstAllBrokerAssets11;
                }
                 if(PageNumber=='12'){lstAllPageBrokerAssets = lstAllBrokerAssets12;
                } 
                 if(PageNumber=='13'){lstAllPageBrokerAssets = lstAllBrokerAssets13;
                } 
                if(PageNumber=='14'){lstAllPageBrokerAssets = lstAllBrokerAssets14;
                } 
                if(PageNumber=='15'){lstAllPageBrokerAssets = lstAllBrokerAssets15;
                }
                 if(PageNumber=='16'){lstAllPageBrokerAssets = lstAllBrokerAssets16;
                }
                return    lstAllPageBrokerAssets;
         }
    
    Public AssetAllBrokerAssetList2Con(){
    baseurl = System.URL.getSalesforceBaseUrl().toExternalForm();
            Set<String> setStatus = new Set<String>{'Active','Cancelled','Converted','Pending Fulfillment'};
            Accid = String.valueOf(ApexPages.CurrentPage().getParameters().get('id')); 
            PageNumber = String.valueOf(ApexPages.CurrentPage().getParameters().get('pn'));  
     setStatus = new Set<String>{'Active','Cancelled','Converted','Pending Fulfillment'};
     Integer ii=0;
    
    for(Asset ast:[Select id,name,MLS_Set__r.Name, Commerce_Group__c, Auto_Renewal__c, BOP_Code__c, Renewal_Status__c ,asset_type__c,Status,parent_asset__c,Quantity,Include_Asset__c,ultimate_parent__c,Start_Date__c,Fulfillment_Status__c,End_Date__c,Lead_Type__c,Total_Net__c,Extended_Net_Price__c from asset where Status = :setStatus and accountId=:Accid and asset_type__c='Parent' order by Status,End_Date__c ASC limit 10000]){  
    if(ii<300 && (PageNumber =='0'||PageNumber==null)){
    lstAllBrokerAssets0.add(ast);
    }
     if((ii>=300 && ii<600)  && (PageNumber =='1')){lstAllBrokerAssets1.add(ast);
    }
     if((ii>=600 && ii<900)  && (PageNumber =='2')){lstAllBrokerAssets2.add(ast);
    }
     if((ii>=900 && ii<1200)  && (PageNumber =='3')){lstAllBrokerAssets3.add(ast);
    }
     if((ii>=1200 && ii<1500)  && (PageNumber =='4')){lstAllBrokerAssets4.add(ast);
    }
     if((ii>=1500 && ii<1800)  && (PageNumber =='5')){lstAllBrokerAssets5.add(ast);
    } 
    if((ii>=1800 && ii<2100)  && (PageNumber =='6')){lstAllBrokerAssets6.add(ast);
    }
     if((ii>=2100 && ii<2400)  && (PageNumber =='7')){lstAllBrokerAssets7.add(ast);
    }
     if((ii>=2400 && ii<2700)  && (PageNumber =='8')){lstAllBrokerAssets8.add(ast);
    } 
     if((ii>=2700 && ii<3000)  && (PageNumber =='9')){lstAllBrokerAssets9.add(ast);
    }
     if((ii>=3000 && ii<3300)  && (PageNumber =='10')){lstAllBrokerAssets10.add(ast);
    }
     if((ii>=3300 && ii<3600)  && (PageNumber =='11')){lstAllBrokerAssets11.add(ast);
    }
     if((ii>=3600 && ii<3900)  && (PageNumber =='12')){lstAllBrokerAssets12.add(ast);
    }
     if((ii>=3900 && ii<4200)  && (PageNumber =='13')){lstAllBrokerAssets13.add(ast);
    } 
     if((ii>=4200 && ii<4500)  && (PageNumber =='14')){lstAllBrokerAssets14.add(ast);
    }
     if((ii>=4500 && ii<4800)  && (PageNumber =='15')){lstAllBrokerAssets15.add(ast);
    }
     if((ii>=4800 && ii<5100)  && (PageNumber =='16')){lstAllBrokerAssets16.add(ast);
    }
    ii++;
    }
    
    }
    
    Public Void SaveAsset(){
    update lstAllPageBrokerAssets;
    }
    Public PageReference Next(){
    ii=0;
    for(Asset ast:[Select id,name,MLS_Set__r.Name, Commerce_Group__c, Auto_Renewal__c, BOP_Code__c, Renewal_Status__c ,asset_type__c,Status,parent_asset__c,Quantity,Include_Asset__c,ultimate_parent__c,Start_Date__c,Fulfillment_Status__c,End_Date__c,Lead_Type__c,Total_Net__c,Extended_Net_Price__c from asset where Status = :setStatus and accountId=:Accid and asset_type__c='Parent' order by Status,End_Date__c ASC limit 10000]){  
    ii++;
    }
    PageReference pr;
    Integer maxString=0;
    if(ii<300){maxString=0;}
    if(ii>=300 && ii<600){maxString=1;}
    if(ii>=600 && ii<900){maxString=2;}
    if(ii>=900 && ii<1200){maxString=3;}
    if(ii>=1200 && ii<1500) {maxString=4;}
    if(ii>=1500 && ii<1800){maxString=5;}
    if(ii>=1800 && ii<2100){maxString=6;}
    if(ii>=2100 && ii<2400){maxString=7;}
    if(ii>=2400 && ii<2700) {maxString=8;}
    if(ii>=2700 && ii<3000){maxString=9;}
    if(ii>=3000 && ii<3300){maxString=10;}
    if(ii>=3300 && ii<3600){maxString=11;}
    if(ii>=3600 && ii<3900) {maxString=12;}
    if(ii>=3900 && ii<4200){maxString=13;}
    if(ii>=4200 && ii<4500){maxString=14;}
    if(ii>=4500 && ii<4800){maxString=15;}
    if(ii>=4800 && ii<5100) {maxString=16;}
    System.debug(ii+'HHHH'+maxString);
    pr  = new PageReference(baseurl+'/apex/AllBrokerAssets?id='+Accid);
    if((PageNumber=='0' || PageNumber==null) && maxString>=1){
                pr  = new PageReference(baseurl+'/apex/AllBrokerAssets?pn=1&id='+Accid);
                }
                if(PageNumber=='1' && maxString>=1){ pr  = new PageReference(baseurl+'/apex/AllBrokerAssets?pn=2&id='+Accid);
                }
                if(PageNumber=='2' && maxString>=2){pr  = new PageReference(baseurl+'/apex/AllBrokerAssets?pn=3&id='+Accid);
                }
                if(PageNumber=='3' && maxString>=3){pr  = new PageReference(baseurl+'/apex/AllBrokerAssets?pn=4&id='+Accid);
                }
                if(PageNumber=='4' && maxString>=4){pr  = new PageReference(baseurl+'/apex/AllBrokerAssets?pn=5&id='+Accid);
                }
                if(PageNumber=='5' && maxString>=5){pr  = new PageReference(baseurl+'/apex/AllBrokerAssets?pn=6&id='+Accid);
                }
                if(PageNumber=='6' && maxString>=6){pr  = new PageReference(baseurl+'/apex/AllBrokerAssets?pn=7&id='+Accid);
                }
                if(PageNumber=='7' && maxString>=7){pr  = new PageReference(baseurl+'/apex/AllBrokerAssets?pn=8&id='+Accid);
                }
                if(PageNumber=='8' && maxString>=8){pr  = new PageReference(baseurl+'/apex/AllBrokerAssets?pn=9&id='+Accid);
                }
                if(PageNumber=='9' && maxString>=9){pr  = new PageReference(baseurl+'/apex/AllBrokerAssets?pn=10&id='+Accid);
                }
                if(PageNumber=='10' && maxString>=10){pr  = new PageReference(baseurl+'/apex/AllBrokerAssets?pn=11&id='+Accid);
                }
                if(PageNumber=='11' && maxString>=11){pr  = new PageReference(baseurl+'/apex/AllBrokerAssets?pn=12&id='+Accid);
                }
                if(PageNumber=='12' && maxString>=12){pr  = new PageReference(baseurl+'/apex/AllBrokerAssets?pn=13&id='+Accid);
                }
                if(PageNumber=='13' && maxString>=13){pr  = new PageReference(baseurl+'/apex/AllBrokerAssets?pn=14&id='+Accid);
                }
                if(PageNumber=='14' && maxString>=14){pr  = new PageReference(baseurl+'/apex/AllBrokerAssets?pn=15&id='+Accid);
                }
                if(PageNumber=='15' && maxString>=15){pr  = new PageReference(baseurl+'/apex/AllBrokerAssets?pn=16&id='+Accid);
                }
                pr.setRedirect(true);
                return pr;
    }
    
    Public PageReference Previous(){
    ii=0;
    for(Asset ast:[Select id,name,MLS_Set__r.Name, Commerce_Group__c, Auto_Renewal__c, BOP_Code__c, Renewal_Status__c ,asset_type__c,Status,parent_asset__c,Quantity,Include_Asset__c,ultimate_parent__c,Start_Date__c,Fulfillment_Status__c,End_Date__c,Lead_Type__c,Total_Net__c,Extended_Net_Price__c from asset where Status = :setStatus and accountId=:Accid and asset_type__c='Parent' order by Status,End_Date__c ASC limit 10000]){  
    ii++;
    }
    PageReference pr;
    Integer maxString=0;
    if(ii<300){maxString=0;}
    if(ii>=300 && ii<600){maxString=1;}
    if(ii>=600 && ii<900){maxString=2;}
    if(ii>=900 && ii<1200){maxString=3;}
    if(ii>=1200 && ii<1500) {maxString=4;}
    if(ii>=1500 && ii<1800){maxString=5;}
    if(ii>=1800 && ii<2100){maxString=6;}
    if(ii>=2100 && ii<2400){maxString=7;}
    if(ii>=2400 && ii<2700) {maxString=8;}
    if(ii>=2700 && ii<3000){maxString=9;}
    if(ii>=3000 && ii<3300){maxString=10;}
    if(ii>=3300 && ii<3600){maxString=11;}
    if(ii>=3600 && ii<3900) {maxString=12;}
    if(ii>=3900 && ii<4200){maxString=13;}
    if(ii>=4200 && ii<4500){maxString=14;}
    if(ii>=4500 && ii<4800){maxString=15;}
    if(ii>=4800 && ii<5100) {maxString=16;}
    System.debug(ii+'HHHH'+maxString);
    pr  = new PageReference(baseurl+'/apex/AllBrokerAssets?id='+Accid);
    if((PageNumber=='0' || PageNumber==null) && maxString>=1){
               // pr  = new PageReference(baseurl+'/apex/AllBrokerAssets?pn=1&id='+Accid);
                }
                if(PageNumber=='1' && maxString>=1){pr  = new PageReference(baseurl+'/apex/AllBrokerAssets?pn=0&id='+Accid);
                }
                if(PageNumber=='2' && maxString>=2){pr  = new PageReference(baseurl+'/apex/AllBrokerAssets?pn=1&id='+Accid);
                }
                if(PageNumber=='3' && maxString>=3){pr  = new PageReference(baseurl+'/apex/AllBrokerAssets?pn=2&id='+Accid);
                }
                if(PageNumber=='4' && maxString>=4){pr  = new PageReference(baseurl+'/apex/AllBrokerAssets?pn=3&id='+Accid);
                }
                if(PageNumber=='5' && maxString>=5){pr  = new PageReference(baseurl+'/apex/AllBrokerAssets?pn=4&id='+Accid);
                }
                if(PageNumber=='6' && maxString>=6){pr  = new PageReference(baseurl+'/apex/AllBrokerAssets?pn=5&id='+Accid);
                }
                if(PageNumber=='7' && maxString>=7){pr  = new PageReference(baseurl+'/apex/AllBrokerAssets?pn=6&id='+Accid);
                }
                if(PageNumber=='8' && maxString>=8){pr  = new PageReference(baseurl+'/apex/AllBrokerAssets?pn=7&id='+Accid);
                }
                if(PageNumber=='9' && maxString>=9){pr  = new PageReference(baseurl+'/apex/AllBrokerAssets?pn=8&id='+Accid);
                }
                if(PageNumber=='10' && maxString>=10){pr  = new PageReference(baseurl+'/apex/AllBrokerAssets?pn=9&id='+Accid);
                }
                if(PageNumber=='11' && maxString>=11){pr  = new PageReference(baseurl+'/apex/AllBrokerAssets?pn=10&id='+Accid);
                }
                if(PageNumber=='12' && maxString>=12){pr  = new PageReference(baseurl+'/apex/AllBrokerAssets?pn=11&id='+Accid);
                }
                if(PageNumber=='13' && maxString>=13){pr  = new PageReference(baseurl+'/apex/AllBrokerAssets?pn=12&id='+Accid);
                }
                if(PageNumber=='14' && maxString>=14){pr  = new PageReference(baseurl+'/apex/AllBrokerAssets?pn=13&id='+Accid);
                }
                if(PageNumber=='15' && maxString>=15){pr  = new PageReference(baseurl+'/apex/AllBrokerAssets?pn=14&id='+Accid);
                }
                if(PageNumber=='16' && maxString>=16){pr  = new PageReference(baseurl+'/apex/AllBrokerAssets?pn=15&id='+Accid);
                }
                pr.setRedirect(true);
                return pr;
    }
    // Initialize setCon and return a list of records
   
   
}