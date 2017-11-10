require "Watir"

@arrWeaponData = []
csvResults = Array.new
csvResults.push("Weapon name;price;quantity")

$strSteamUrl = "https://steamcommunity.com/market/listings/730/"
$arrWeaponData = File.readlines("cs_weaponslist.txt")
weaponDataLen = $arrWeaponData.size

$browser = Watir::Browser.new :firefox

# Loop through weaponlist
$arrWeaponData.each_with_index do |weapon, weaponIndex|
   puts "[#{weaponIndex+1} / #{weaponDataLen}] :: Processing #{weapon}"
   $browser.goto $strSteamUrl + weapon
   $browser.element(:class => "responsive_page_content").wait_until_present(timeout: 10)
   $browser.div(:id => 'market_buyorder_info_show_details').span.click
   $cells = $browser.table(:class => "market_commodity_orders_table").tds

   weapon = weapon.sub! "\n", ""

   csvResults.push(weapon)

   # Loop through price summary table
   $cells.each_with_index do |item, index|
      str = item.text
   
      if str.include? "$"
         str = str.sub! "$", ""
      elsif str.include? "\128"
	     str = str.sub! "\128", ""
      end
   
      if index < 2
         csvResults[-1] = csvResults[-1] + ";" + str
      elsif index.even?
         csvResults.push(";#{str}")
      else
         csvResults[-1] = csvResults[-1] + ";" + str
      end
   end 
   
   puts "Sleeping for 10 sec..."
   sleep(10)
end

#p csvResults

open('result.csv', 'w') do |file|
  csvResults.each do |item|
     file.puts item
  end
end
