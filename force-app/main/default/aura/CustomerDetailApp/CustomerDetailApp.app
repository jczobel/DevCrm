<aura:application
  access="GLOBAL"
  extends="ltng:outApp"
  implements="ltng:allowGuestAccess"
>
  <c:CustomerDetail />
  <aura:dependency resource="markup://force:refreshView" type="EVENT" />
</aura:application>