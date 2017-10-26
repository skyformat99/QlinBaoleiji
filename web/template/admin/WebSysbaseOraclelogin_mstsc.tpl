{{if $smarty.session.urlprotocol eq 1}}baoleiji{{else}}freesvr{{/if}}://\"&action=StartMstscAutoRun&autorun={{$autorun}}&host={{$host}}&port={{$port}}&username={{$username}}&password={{$password}}&path={{$path}}&param={{$param}}&disconnectsecouldapp={{$disconnectsecouldapp}}&&debug={{$smarty.session.ADMIN_FREESVRDEBUG}}&sshport={{$member.sshport}}&rdpport={{$member.rdpport}}&showdomain={{$showdomain}}&hostname={{$hostname|urlencode}}&rdpclientversion={{$rdpclientversion}}&\"


