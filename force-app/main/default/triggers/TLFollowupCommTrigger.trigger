trigger TLFollowupCommTrigger on TL_Follow_Up_Communication__c (before Update) {

    Set<Id> setTL = new Set<Id>();

    for(TL_Follow_Up_Communication__c TL : trigger.new)
        if(TL.Status__c == 'Completed')
            setTL.add(TL.Id);

    Map<Id, List<Case>> mapTLToCase
        = new Map<Id, List<Case>>();

    for(Case TLCase :
        [
            SELECT
                Id, TL_Coaching__c
            FROM
                Case
            WHERE 
                TL_Coaching__c IN :setTL AND
                Status != 'Closed'
        ]       
    )
    
    {
        if(
            !mapTLToCase.containsKey(
                TLCase.TL_Coaching__c
            )
        ){
            mapTLToCase.put(
                TLCase.TL_Coaching__c,
                new List<Case>{
                    TLCase
                }
            );
        }
        else{
            mapTLToCase.get(
                TLCase.TL_Coaching__c
            ).add(TLCase);
        }
    }

    for(TL_Follow_Up_Communication__c TL : trigger.new){
        if(TL.Status__c == 'Completed'){
            if(
                mapTLToCase.containsKey(TL.Id) &&
                mapTLToCase.get(
                    TL.Id
                ).size() > 0
            ){
                TL.addError(
                    'You cannot Mark this as Complete. ' + 
                    'There are Open Cases ' + 
                    'under this.'
                );
            }
        }
    }
}