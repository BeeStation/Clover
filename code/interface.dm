/client
	verb
		changes()
			set category = "Commands"
			set name = "Changelog"
			set desc = "Show or hide the changelog"

			if (winget(src, "changes", "is-visible") == "true")
				src.Browse(null, "window=changes")
			else
				var/changelogHtml = grabResource("html/changelog.html")
				var/data = changelog:html
				changelogHtml = replacetext(changelogHtml, "<!-- HTML GOES HERE -->", "[data]")
				src.Browse(changelogHtml, "window=changes;size=500x650;title=Changelog;", 1)
				src.changes = 1

		bugreport()
			set category = "Commands"
			set name = "bugreport"
			set desc = "Report a bug."
			set hidden = 1

			if(!config.gitreports)
				src << link("[config.github_repo_url]/issues/new?template=bug_report.md")
				return

			switch(alert(src, "Do you have a GitHub account?",,"Yes","No","Cancel"))
				if("Yes")
					src << link("[config.github_repo_url]/issues/new?template=bug_report.md")
				if("No")
					var/details_body = {"**Describe+the+bug**%0AA+clear+and+concise+description+of+what+the+bug+is.%0A%0A**To+Reproduce**%0ASteps+to+reproduce+the+behavior:%0A1.+Buy+a+Pizza+from+a+vending+machine%0A2.+Eat+the+pizza%0A3.+The+pizza+has+not+disappeared%0A4.+See+error%0A%0A**Expected+behavior**%0AA+clear+and+concise+description+of+what+you+expected+to+happen.%0A%0A**Screenshots**%0AIf+applicable,+add+screenshots+to+help+explain+your+problem.%0A%0A**Additional+context**%0AAdd+any+other+context+about+the+problem+here.%0A%0A"}
					var/url = {"https://gitreports.com/issue/[config.gitreports]?email_public=0&name=[src.ckey]&details=[details_body]%0AReported on: [config.server_name]+[time2text(world.realtime, "YYYY-MM-DD")]+[time2text(world.timeofday, "hh:mm:ss")]"}
					src << link(url)
				if("Cancel")
					return

		github()
			set category = "Commands"
			set name = "github"
			set desc = "Opens the github in your browser"
			set hidden = 1
			src << link("[config.github_repo_url]")

		wiki()
			set category = "Commands"
			set name = "Wiki"
			set desc = "Open the Wiki in your browser"
			set hidden = 1
			src << link("[config.wiki_url]")

		map()
			set category = "Commands"
			set name = "Map"
			set desc = "Open an interactive map in your browser"
			set hidden = 1
			if (map_settings)
				src << link(map_settings.goonhub_map)
			else
				src << link("[config.map_webview_url]")

		forum()
			set category = "Commands"
			set name = "Forum"
			set desc = "Open the Forum in your browser"
			set hidden = 1
			src << link("[config.forums_url]")

		savetraits()
			set hidden = 1
			set name = ".savetraits"
			set instant = 1

			if(preferences)
				if(preferences.traitPreferences.isValid())
					preferences.ShowChoices(usr)
				else
					alert(usr, "Invalid trait setup. Please make sure you have 0 or more points available.")
					preferences.traitPreferences.showTraits(usr)

	proc
		set_macro(name)
			winset(src, "mainwindow", "macro=\"[name]\"")
