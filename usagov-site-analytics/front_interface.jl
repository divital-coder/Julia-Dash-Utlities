using Pkg;
Pkg.add("Dash"); #this enables us to launch our web app
Pkg.add("Plotly"); #this enables us to create plots and graphs

include("./data_stuff.jl");
include("./data_logic.jl");
include("./front_data_manipulation.jl");
using Dash;
using PlotlyJS;
#for dropdowns u need an options attribute ,and that attribute needs  an array of dictionary with key value pairs of label and value
# this functions returns a value which the user have chosen from the dropdown menu
function return_agency_from_the_dropdown(agency_name)
lowercased_agency_name = lowercase(agency_name);
return lowercased_agency_name;
end


# GLOBAL VARAIBLES 
#--------------------------------------------LARGE DATA SETS--------------------------------------
TOP_DOMAIN_DATA_DICT = nothing;
ALL_PAGES_REALTIME_DATA_DICT = nothing;
TOP_COUNTRIES_REALTIME_DATA_DICT = nothing;
TOP_CITIES_REALTIME_DATA_DICT = nothing;
DOWNLOAD_REPORT_DATA = nothing;
TOP_TRAFFIC_SOURCES_30_DAYS_REPORT_DATA = nothing;
#------------------------------------------------LARGE DATA SETS--------------------------------------------

#-----------------------------------FINALISED DATA VARIABLES VALUES---------------------------------
FINAL_WEEKLY_DOMAIN_DATA = nothing;
FINAL_MONTHLY_DOMAIN_DATA = nothing;
FINAL_NOW_PAGES_DATA = nothing;
#-----------------------------------FINALISED DATA VARIABLES VALUES------------------------------------
#global variables


header_agency_dropdown_options = fetch_agency_names("agency_dropdown_options");


#here we are simply storting and creating the html and css layout for our app
frontend_layout =  html_div(children=[
    html_header(children=[
        html_img(src="./assets/usagov_logo.png",alt="USA GOV LOGO", className = "usagov_logo"),
        html_h1("USA GOVERNMENT WEBSITE ANALYTICS", className = "site_heading"),
        dcc_dropdown(options=header_agency_dropdown_options, value=header_agency_dropdown_options[1]["value"], style=Dict("border"=>"none","display"=>"flex","align-items"=>"center","justify-content"=>"center","text-align"=>"center","border-radius"=>"40px","cursor"=>"pointer","color"=>"black","font-family"=>"sans-serif"), id="agency_dropdown"),
        html_div(children=[
        html_a("usa.gov", href="https://usa.gov", className = "site_redirect_link")],className="site_redirect_link_container"),
        ], className = "content_header"),
# main section of the page 
        html_div(
            children = [
        # left pane things  
        html_div(children= [
            html_h2("Most Popular"),
            dcc_tabs(children = [
                dcc_tab(label="Top Domains\n(Past Week)",value="weekly_domains"),
                dcc_tab(label="Top Domains\n(Past Month)",value="monthly_domains"),
                dcc_tab(label="Top Pages\n(Now)", value="pages_now")
            ])] ,id="left_pane_tabs"),              
        # right pane things 
        html_div(
                children=[
                html_h1("apple")
                ],    
                className="right_pane")]),

# footer section of the page 
        html_footer(children=[
            html_p("made with love by "),
            html_a("@hurtbadly2", href = "https://x.com/hurtbadly2", className = "footer_redirect_link")
        ], className = "site_footer")
    ]);









Application = dash(external_stylesheets=["./assets/styles.css"]);
Application.title = "usa.gov | Site Analytics";
Application.layout = frontend_layout;


 

# callbacks related to our application
callback!(Application,Output("showthis","children"),Input("agency_dropdown","value"))do selected_agency_option 
    lowercased_agency_name = return_agency_from_the_dropdown(selected_agency_option);
    # need to call the function that fetches data for the relevant agency 
    TOP_DOMAIN_DATA_DICT = fetch_site_report_data_from_mongodb(lowercased_agency_name); #this returns a dictionary with keys "monthly_domain_data", "weekly_domain_data", "now_domain_data" which are arrays of dictionaryies with key "domain", "visits"
    ALL_PAGES_REALTIME_DATA_DICT = fetch_all_pages_realtime_report_data_from_mongodb(lowercased_agency_name);
    TOP_COUNTRIES_REALTIME_DATA_DICT = fetch_top_countries_realtime_report_data_from_mongodb(lowercased_agency_name);
    TOP_CITIES_REALTIME_DATA_DICT = fetch_top_cities_realtime_report_data_from_mongodb(lowercased_agency_name);
    DOWNLOAD_REPORT_DATA = fetch_download_report_data_from_mongodb(lowercased_agency_name);
    TOP_TRAFFIC_SOURCES_30_DAYS_REPORT_DATA = fetch_top_traffic_sources_30_days_report_data_from_mongodb(lowercase_agency_name);    
end


callback!(Application,Output("graph","children"),Input("left_pane_tabs","value")) do tab_value
if tab_value == "weekly_domains"
    FINAL_WEEKLY_DOMAIN_DATA = finalise_top_domains_past_week(TOP_DOMAIN_DATA_DICT["weekly_domain_data"]);    
elseif tab_value == "monthly_domains"
    FINAL_MONTHLY_DOMAIN_DATA = finalise_top_domains_past_month(TOP_DOMAINS_DATA_DICT["monthly_domain_data"]);
elseif tab_value == "pages_now"
    FINAL_NOW_PAGES_DATA = finalise_top_pages_now(TOP_DOMAINS_DATA_DICT["now_domain_data"]);
end
end
    
    

run_server(Application,"0.0.0.0",debug=true);




