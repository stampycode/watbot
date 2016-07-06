# Description:
#   Prints Jira ticket information when a ticket is seen in conversation
#
# Configuration:
#   Requires credentials for Jira given in the ENV var HUBOT_JIRA_CREDS in the form of
#   username:password
# 

auth = process.env.HUBOT_JIRA_CREDS

module.exports = (robot) ->

  robot.hear /(?:^|[^A-Za-z0-9]|debug )([A-Z]{2,4}-[1-9][0-9]{1,4})(?:[^0-9A-Za-z]|$)/, (res) ->
    ticket = res.match[1];
    res.http("https://jira.rakutenmarketing.com/rest/api/2/issue/#{ticket}", { auth: auth } )
      .header('User-Agent', 'Slackbot')
      .get() (error, response, body) ->
        if response.statusCode isnt 200
          if res.match[0].match(/debug/)
            res.send "Debug: response from Jira was #{response.statusCode}"
          return;
        result = JSON.parse(body);
        msgData = {
          attachments: [
            {
              fallback: "Ticket #{ticket}",
              fields: [
                {
                  title: "Summary",
                  value: result['fields']['summary'],
                  short: false
                },{
                  title: "Type",
                  value: result['fields']['issuetype']['name'],
                  short: true
                },{
                  title: "Status",
                  value: result['fields']['status']['name'],
                  short: true
                },{
                  title: "Assigned To",
                  value: result['fields']['assignee']['displayName'],
                  short: true
                }
              ],
              title: "Ticket #{ticket}",
              title_link: "https://jira.rakutenmarketing.com/browse/#{ticket}",
              text: result['fields']['description'],
              thumb_url: "https://a.slack-edge.com/ae7f/plugins/jira/assets/service_512.png",
              color: "green"
            }
          ]
        }
        robot.emit 'slack.attachment', msgData
