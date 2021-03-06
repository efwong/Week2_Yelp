# Project 2 - Yelp

Yelp is a Yelp search app using the [Yelp API](http://www.yelp.com/developers/documentation/v2/search_api).

Time spent: 12 hours spent in total

## User Stories

The following **required** functionality is completed:

- [x] Search results page
   - [x] Table rows should be dynamic height according to the content height.
   - [x] Custom cells should have the proper Auto Layout constraints.
   - [x] Search bar should be in the navigation bar (doesn't have to expand to show location like the real Yelp app does).
- [X] Filter page. Unfortunately, not all the filters are supported in the Yelp API.
   - [x] The filters you should actually have are: category, sort (best match, distance, highest rated), distance, deals (on/off).
   - [x] The filters table should be organized into sections as in the mock.
   - [x] You can use the default UISwitch for on/off states.
   - [x] Clicking on the "Search" button should dismiss the filters page and trigger the search w/ the new filter settings.
   - [x] Display some of the available Yelp categories (choose any 3-4 that you want).

The following **optional** features are implemented:

- [ ] Search results page
   - [x] Infinite scroll for restaurant results.
   - [ ] Implement map view of restaurant results.
- [ ] Filter page
   - [ ] Implement a custom switch instead of the default UISwitch.
   - [ ] Distance filter should expand as in the real Yelp app
   - [ ] Categories should show a subset of the full list with a "See All" row to expand. Category list is [here](http://www.yelp.com/developers/documentation/category_list).
- [x] Implement the restaurant detail page.

The following **additional** features are implemented:
- [x] Added map view of restaurant result inside restaurant detail page
- [x] When opening the filters view, the most recent filter will be prepopulated. If no previous filter was used before, it will default to sort: BestMatched, distance: Auto, deals: off, categories: none.  Does not save filters between sessions(open/close app)
- [x] Added a reset button to clear filters. Will only save the reset, if the save button is clicked
- [x] Added table view infinite scroll loader and UIBlocker while waiting for API calls
Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):
- [x] Added ability to call business phone number in details page, but it does not actually open up the phone number app because it's a simulator

1. How to implement a dropdown using the tableview
2. Should search filters fire after every keystroke or should we force the user to press enter?

## Video Walkthrough

Here's a walkthrough of implemented user stories:

[YelpGif](http://i.imgur.com/tbfbFEt.gifv)

![Video Walkthrough](yelp.gif)

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

Describe any challenges encountered while building the app.

I felt that the Settings View was a challenge to complete.  There were multiple categories so I needed to maaintain a 2d array keeping track of the section (deal,section,distance,category) and the individual row.  I ran into bugs where I was referencing the incorrect section.  When I have time I would like to go back and try to refactor/streamline this section to be more readable and efficient.  

## License

    Copyright [yyyy] [name of copyright owner]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.