import strutils, jester, system, httpClient, json, base64, streams, templates, times

type
  Item = object
    update : string 
    project : string
    summary : string
    url : string
    broUrl : string

proc issues (host: string, usr: string, pwd: string, d: int): seq[Item] =
  let key = "Basic " & encode(usr & ":" & pwd)
  let client = newHttpClient()
  client.headers = newHttpHeaders({ "Authorization" : key })
  let response = client.get("http://" & host & "/rest/api/2/search?jql=updated++>=++\"-" & $d & "d\"")
  let jira = parseJson(response.body )
  var rs : seq[Item] = @[]
  for i in jira["issues"]:
    let proj = i["fields"]["project"]["key"].getStr()
    let sm   = i["fields"]["summary"].getStr()
    let up   = i["fields"]["updated"].getStr()
    let ur   = "http://" & host & "/browse/" & i["key"].getStr()
    let bro  = "http://" & host & "/projects/" & proj & "/summary" 
    let item = Item(update : up, project : proj, summary : sm, url : ur, broUrl : bro)
    rs.add(item)
  rs


proc viewIssues (d: int): string = 
    let ini = newFileStream("ini.txt", fmRead)
    let host = ini.readLine()
    let usr = ini.readLine()
    let pwd = ini.readLine()
    let exp = ini.readLine()
    ini.close()
    let dx =  if d == 0 : parseInt(exp) else : d
    let items = issues(host, usr, pwd, dx)
    let nw = now()
    tmpli html"""
	<body link="red" >
	<script>
	function link(id) { id.setAttribute('style', 'color:green;'); }
	</script>
        <h1>Summary lines at $(nw)</h1>
        <pre>Changes in <input type="number" min="1" value="$(dx)" id="d" style="width: 70px"> days  <a href="$(dx)" onclick="{this.href=document.getElementById('d').value;}">Update</a></pre>
            <table cellspacing="2" cellpadding="10" border="1">
		<thead>
		<tr style="font-weight: bold">
			<td>Update Time</td>
			<td>Issue</td>
			<td>Project</td>		
		</tr>
		</thed>
                $for item in items {
                    <tr>
                    <td>$(item.update)</td>
<td>
                    <a href=$(item.url) target="_blank" onclick="javascript: link(this);">$(item.summary)</a>
</td>
<td>
                    <a href=$(item.broUrl) target="_blank" onclick="javascript: link(this);">$(item.project)</a>
</td>
		    </tr>
                }
            </table>
    </body>
    """

proc  d(a : string) : int = 
    try:
      result = parseInt(a)
    except:
      result = 0


routes:
  get "/@id?":
    resp viewIssues((d(@"id")))