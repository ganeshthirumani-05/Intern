import argparse
import requests

parser = argparse.ArgumentParser(description="Population of the united states by the Year :")
parser.add_argument("-y", help="Year shoulb be from 2013 to 2019", type=int, action="store", metavar="Year to find the population of USA", dest="year_given")
args = parser.parse_args()

year_of_population = args.year_given


def return_year_population(population_api):
    try:
     population = population_api['data'][0]['Population']
     return population
    except:
        print("Input out of bounds. Year should be from 2013 to 2019")


try:
    base_url = "https://datausa.io/api/data?drilldowns=Nation&measures=Population"

    query_url_attaching_year = 'Year='+str(year_of_population)

    population_api_response = requests.get(base_url, params=query_url_attaching_year)

    print("The status code is: ", population_api_response.status_code)

    population_api_response_json = population_api_response.json()

    population_of_the_country = return_year_population(population_api_response_json)

    print("The population of the year", year_of_population, "is" ,population_of_the_country)


except:
    print("Invalid url. Please provide a valid url")
