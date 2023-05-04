$Query = @"
<QueryList>
  <Query Id="0" Path="file://C:\Users\Fernando\Desktop\Security.evtx">
    <Select Path="file://C:\Users\Fernando\Desktop\Security.evtx">*[System[(EventID=4624)]]</Select>
  </Query>
</QueryList>
"@

Get-WinEvent -FilterXml $Query