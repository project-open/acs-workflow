<!-- Tab bar -->
<table border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td>&nbsp;</td>
      <multiple name="tabs">
        <if @tabs.key@ eq @tab@>
          <td bgcolor="#999999">&nbsp;<font color="#eeeeff">@tabs.name@</font>&nbsp;</td>
        </if>
        <else>
          <td>&nbsp;<a href="@tabs.url@">@tabs.name@</a>&nbsp;</td>
        </else>
      </multiple>
    <td width="100%">&nbsp;</td>
  </tr>
  <tr bgcolor="#999999">
    <td colspan="<%=[expr {${tabs:rowcount}+2}]%>"></td>
  </tr>
</table>
