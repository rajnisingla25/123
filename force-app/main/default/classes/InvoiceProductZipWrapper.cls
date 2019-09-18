Public Class InvoiceProductZipWrapper{
Public Integer RecordNumber{get;set;}
Public String InvoiceId{get;set;}
Public String InvoiceName{get;set;}
Public String ProductCode{get;set;}
Public String MarketCode{get;set;}
Public List<String> lstMarketCode = new List<String>();
Public List<String> getlstMarketCode(){
return lstMarketCode;
}

}