<aura:application extends="force:slds">
    <c:cybsPaymentCmp/>  
    
    <aura:attribute name="vfHost" type="String" 
        default="https://moveinc--rdev--c.cs37.visual.force.com"/>
    <aura:handler name="init" value="{!this}" action="{!c.doInit}"/>

</aura:application>