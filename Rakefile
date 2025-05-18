require 'json'

task :default => [:release]

task :release do 
    VERSION = ENV["VERSION"] || "1.0.0"
    archive = "./releases/ReNaMeLaYeRs.#{VERSION}-#{`uuidgen | head -c 4`}.sketchplugin.xcarchive"
    plugin = "#{archive}/Products/Library/Application Support/com.bohemiancoding.sketch3/Plugins/ReNaMeLaYeRs.sketchplugin"
    plugin_zip = "#{plugin}.zip"
    
    sh "xcodebuild -scheme 'ReNaMe LaYeRs' -archivePath #{archive} -configuration Release -quiet archive"
    sh "ditto -c -k --sequesterRsrc --keepParent '#{plugin}' '#{plugin_zip}'"
    notarize(plugin_zip)
end

def notarize(plugin_zip)
    fail "[!] Environment variable NOTARIZATION_USER is not set" unless ENV['NOTARIZATION_USER']
    fail "[!] Environment variable NOTARIZATION_TEAM is not set" unless ENV['NOTARIZATION_TEAM']
    fail "[!] Environment variable NOTARIZATION_PASSWORD is not set" unless ENV['NOTARIZATION_PASSWORD']

    def notarytool_credentials()
        return "--team-id '#{ENV['NOTARIZATION_TEAM']}' --apple-id '#{ENV['NOTARIZATION_USER']}' --password '#{ENV['NOTARIZATION_PASSWORD']}'"
    end

    def fetch_notarization_log(submission_id)
        return `xcrun notarytool log #{notarytool_credentials()} --output-format json #{submission_id}`
    end

    response = JSON.parse(`xcrun notarytool submit #{notarytool_credentials()} --output-format json --wait '#{plugin_zip}'`)

    fail "[!] Unable to parse the notarization response for #{plugin_zip}. Please try again" unless response
    fail "[!] Invalid notarization response: #{response} for #{plugin_zip}. Please try again" unless response['id']

    submission_id = response["id"]
    status = response["status"]

    puts "#{fetch_notarization_log(submission_id)}"

    fail "[!] Notarization failed. See the log above" unless status == "Accepted"
end
