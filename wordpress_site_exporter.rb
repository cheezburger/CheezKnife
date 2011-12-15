# Assumes curl is included in your path.

require "FileUtils"

def download_export_from(from_year, through_year, backup_directory, root_url, username, password)
  `curl -i -L --data "log=#{username}&pwd=#{password}" --cookie wordpress_cookies --cookie-jar wordpress_cookies --location wordpress_cookies.txt "http://cheezdailysquee.wordpress.com/wp-login.php"`
  (from_year..through_year).each do |start_year|
    (1..12).each do |start_month|
      if start_month == 12
        end_year = start_year + 1
        end_month = 1
      else
        end_year = start_year
        end_month = start_month + 1
      end
      
      FileUtils.rm_rf backup_directory if !File.directory? backup_directory
      FileUtils.mkdir backup_directory if !File.directory? backup_directory
      exported_file_name = "#{backup_directory}/#{start_year}#{start_month}_#{end_year}#{end_month}.wxr"
      
      puts "Starting download of #{exported_file_name} for #{start_month}/#{start_year} through #{end_month}/#{end_year}"
      
      `curl -i -L --cookie wordpress_cookies --location "http://#{root_url}/wp-admin/export.php?mm_start=#{start_year}-#{start_month}&mm_end=#{end_year}-#{end_month}&author=all&export_taxonomy%5Bcategory%5D=0&export_post_type=all&export_post_status=publish&submit=Download+Export+File&download=true" -o #{exported_file_name}`
      
      if not File.exists? exported_file_name
        puts "Shit went sour. File can't be downloaded but Wordpress all playing it cool like we dun got it wrong."
        puts "Sleeping for a few seconds to see if file becomes available"
        sleep 10
        `curl -i -L --cookie wordpress_cookies --location "http://#{root_url}/wp-admin/export.php?mm_start=#{start_year}-#{start_month}&mm_end=#{end_year}-#{end_month}&author=all&export_taxonomy%5Bcategory%5D=0&export_post_type=all&export_post_status=publish&submit=Download+Export+File&download=true" -o #{exported_file_name}`
        puts "#{exported_file_name} "
      end
    end
  end
end

login = "username"
pw = "password"

# Examples
# download_export_from(2010, 2011, "exported_files/cheezdailysquee", "cheezdailysquee.wordpress.com", login, pw)
# download_export_from(2010, 2011, "exported_files/bronies", "bronies.memebase.com", login, pw)
# download_export_from(2010, 2011, "exported_files/thereifixedit", "thereifixedit.failblog.org", login, pw)