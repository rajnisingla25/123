Public class AssetStructure{
Public String Type{get;set;}
Public String SoldToaccountId{get;set;}
Public String assetId{get;set;}
Public Integer parentlevel{get;set;}
Public Decimal HLC{get;set;}
Public Decimal HLCOverride{get;set;}
Public List<fulfillTo> fulfillTo{get;set;}

Public Class fulfillTo{
Public String Type{get;set;}
Public String FulfillToaccountId{get;set;}
Public String assetId{get;set;}
Public Integer fulfilltolevel{get;set;}
Public Decimal HLC{get;set;}
Public Decimal HLCOverride{get;set;}
Public List<participant> participant{get;set;}

}
Public Class participant{
Public String Type{get;set;}
Public String participantaccountId{get;set;}
Public String assetId{get;set;}
Public String MLSSETID{get;set;}
Public Integer participantlevel{get;set;}
Public Decimal HLC{get;set;}
Public Decimal HLCOverride{get;set;}
}

}