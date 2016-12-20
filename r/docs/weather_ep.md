# EP Variable Descriptions

For original variable descriptions see
[ASOS Network](https://mesonet.agron.iastate.edu/request/download.phtml?network=NY_ASOS).
Some variables were renamed and converted to Système international d'unités, SI.

| Variable   | Description                             |
| :--------- | :-------------------------------------- |
| station    | Three or four character site identifier |
| time       | Timestamp of the observation |
| temp       | Air Temperature in Celsius, typically @ 2 meters |
| dewp       | Dew Point Temperature in Celsius, typically @ 2 meters |
| humid      | Relative Humidity in % |
| wind_dir   | Wind Direction in degrees from north |
| wind_speed | Wind Speed in km/h |
| wind_gust  | Wind Gust in km/h |
| precip     | One hour precipitation for the period from the observation time to the time of the previous hourly precipitation reset. This varies slightly by site. Values are in inches. This value may or may not contain frozen precipitation melted by some device on the sensor or estimated by some other means. Unfortunately, we do not know of an authoritative database denoting which station has which sensor. |
| pressure   | Sea Level Pressure in millibar (missing in EPGD data)|
| visib      | Visibility in kilometers |

Plus extra convenience variables: year, month, day, hour, minute, time_hour.
