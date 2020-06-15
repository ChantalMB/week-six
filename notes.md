# Week 6: Notes

- Oh I am ABSOLUTELY analyzing a diary
  - Primary interest is social history --> I love learning the nitty gritty details of a person's life
  - Small details reveal the most about daily life and the society that person lived in
  - Generating a greater topic to research might be more difficult when analyzing a single person's diary, but it should at least be informative
- I seem to have issues when it comes to digital history because I never know where to start --> gotta make a game plan
- A lot of the diaries I'm interested in aren't in English...

### Plan
- SELECTED: Diary of Cecilia Beaux
  - Never heard of her so it should make things more interesting --> as questions arise from my data, I can look them up and learn more
  - What I do know from the short description about her:
    - Portrait painter in US
    - Work desired during the late 1800s and early 1900s
  - Curious that her diary is mostly typewritten --> the segment of her diary that has been digitized seems to be from the year 1912
    - Health?
    - Where did she live?
    - What was her status?
    - How does her gender impact her life as an artist in 1912? Does it?
    - Political views?
- To Do
  - Try and get pages of diary via wget
  - OCR the files --> this diary has already been transcribed by the smithsonian but it doesn't seem like you can download the text files
    - Combine files into one larger text file --> can this be done at the same time?
  - Clean up with REGEX
  - Use Voyant to analyze/visualize text --> see what questions arise from here
  - Topic model to explore broad themes in her life further
- Maybe a poster to sum it all up???

### Wget
- URLs for individual pages are formatted inconsistently --> going to see if I can grab all of the papers from main page using simple wget command first
  - ```wget -r -np -w 2 --limit-rate=20k https://transcription.si.edu/project/7362```
  - Does not work --> just gave me the website assets
- Ran it but specified individual page --> wget is downloading the html of the webpage
- Opened up the inspect element tool to look at the HTML of a webpage showing an individual diary entry to look more closely at how it's formatted
  - The transcribed text is embedded in the page :( --> can you use wget to pull info from a variable in the HTML of a page?
    - Nope you can only pull the whole page
  - The pages are shown within a container --> container linked to varible that references another webpage --> ```data-idsid="https://www.aaa.si.edu/assets/images/beauceci/fullsize/AAA_beauceci_52680.jpg"```
    - The direct collection the displays ALL of the original scans/images has restricted access --> why???
    - Went through the HTML of the first 3 individual diary pages --> restricted URL seems to label original scans consecutively...
      - TEST: If I go to page 50, the image number should be 52724 --> it was 52723, 1 number off
      - Perhaps blank pages was omitted from transcription project?
  - Despite numbers being off I'm going to write a small script to try and pull all the pages anyway
    - Success! After 27m 8s all pages are downloaded!

### OCR
- Okay so I want all of this text in one file --> can I do this and have it format in a somewhat readable way??? we shall see
  - Making a blank text file to paste ocr text into
  - Tesseract giving ```Image too small to scale!!``` error --> when testing a couple individual outputs everything looks fine though, so I'm ignoring for now
    - Google says it's caused by small fonts so it shouldn't be a large issue --> may result in strange looking "word"
  - Test works --> each entry is appended to desginated text file
    - She seems to have written multiple entries on a single page --> fix using regex later
- Everything successfully OCR'd!

### REGEX
- First I want to isolate each entry --> space out each entry by date for readability
  - PROBLEM: Went straight into regex, didn't realize Cecilia really enjoys using shorthand in her diary --> ctrl + z
- Probably best to actually review the text file first --> got over-excited
  - Lots of shorthand
  - Definitely a few lines missing --> likely linked to the Tesseract + small fonts issue
  - Lots of misread characters and random characters at end of entry--> I think the copyright overlay on images messed up the OCR a bit
  - There's like, a section with total gibberish?
    - Investigated image files --> looks like Cecilia just did like 5 pages written by hand that even I can barely read so I don't blame Tesseract here
  - Lots of missed notes that are hand written in the margins
- Too much shorthand for Open Refine to somehow be applied to this...
  - Regex would take hours
  - If only I could get the verified and corrected transcripts embedded in the website...


### CHANTAL LEARNS WEBSCRAPING
- I'm assuming this will be faster than trying to make the OCR text useable, considering I also now have to attempt to pull handwriting as well
- Inspecting the HTML of the [homepage](https://transcription.si.edu/project/7362) of this archive, going through the content until one image box is highlighted, as expected, each clickable box contains a link to the individual page's page (where the transcribed text is embedded)
- Gotta get those links --> pages for journal pages not sequential
  - [Starting point](https://bradleyboehmke.github.io/2015/12/scraping-html-text.html) --> quick success from this tutorial but I'm only getting 8 of the urls
  - PROBLEM LOCATED: I access the page but the initial state of the page only loads the first 8 pages --> the archive is scroll-to-load
  - Google introduces RSelenium, which will load the page and scroll through it for me, so convinient
    - Don't have Docker installed atm, don't feel like installing it, just gonna use rsDriver and assign it to be remote
    - Used the scroll function in for loop --> Page is fully loaded!
  - Have the page's full HTML now but I need to save the contents of html_attr, which doesn't seem to be something I can assign to a variable
  - [Found solution](https://stackoverflow.com/questions/43598427/r-how-to-extract-items-from-xml-nodeset) that suggests using sapply and doing scraping within function --> SUCCESS! Now I have a... matrix???
  - I want a list of links --> lists easier to manipulate in R and I still need to append these half links to the main half of the URL
    - [Iterating through the matrix](https://campus.datacamp.com/courses/intermediate-r-for-finance/loops-3?ex=11) --> make the full link via paste and add that "link" to new list
  - Links I need have been GOT!
- Want to paste the transcribed text into a single text file (like what I did with the OCR'd text)
  - For loop to go over each element of list of links
    - ```$navigate``` doesn't want to navigate to element variable --> used paste to create variable with element
    - Content of this loop is basically what I just wrote to get list of links ha
  - Need to add the text I got from each ```pre``` section from each page to designated text file
    - Trying with ```lapply``` and ```write``` function
    - Ran this for loop --> seems like it's going too fast I feel like it must not be working right
  - IT WORKED! I HAVE THE VERIFIED, CHECKED-BY-VOLUNTEERS TEXT!!
- Making a 2nd txt file that also grabs the image names and appends them to their respective entries so if I need to I can cross reference with the downloaded images


### Back to REGEX
- Just going to delete transcription of first page --> describes logo of the journal/folder she kept her entries in
- Not going to bother separating by dates --> pulling from individual (web)pages made it so there's no weird spacing making entries hard to identify
- Find references to formatting and delete --> can find formatting from scans later if needed
  - Went through data quick to pull common terms, made one long expression: ```\[\[(vertical.+?|left.+?|underline.+?|overwritten.+?|strikethrough.+?|hand.+?|double.+?|image.+?|strikeover.+?| .+?|/.+?)\]\]```
  - Went over overstrikes and penciled things individually to make sure they weren't important
- Unknown/misspelled text and notes marked by "[[]]" --> find these first
  - Reviewing the text by just searching "[[", it seems that I only want to remove the square brackets that have text directly attached --> these indicate word corrections of Cecilia's typos
  - Expression ```(\w[^ |^\n])(\[\[(.*)\]\])([ |\.])``` works to find the word corrections, but if there's multiple corrections on the same line then it finds from the first pair of square brackets to the very last
  - Fixed using ```.+?```
- Find leftovers using ```\[\[(.+?)\]\]``` --> quick scroll to make sure all was well then replaced with contents of $1
  - Interesting how Cecilia occasionally strikes through names or adds more "saucy" thoughts in the margins
  - Remove question marks --> Cecilia never used them in her writing
- Alright, should be clean enough now
  - Do wish I could remove the segmented words somehow --> can see that being an issue in text analysis
  - Segments probably due to odd spacing typewriters create


### Voyant
- Going to continue to use web tool
- I was right about the word fragments --> quick filter the most common ones using regex
  - fr was from
  - sl a person? --> checking scans
    - Verified it is a name --> Cecilia often mentions people in her journal by letter, who are these people?
- Reuploaded file is much better with translated shorthand
  - [Corpus](https://voyant-tools.org/?corpus=bc15d5cd2bfd1a8c68769a9ce127daf7)
- Observations
  - Top 5 words mostly "transient" -> came, got, went all imply action
  - Contexts
    - Looking at 'came' --> reveals most frequent acquaintances
      - Sl unsurprisingly
        - Searching Sl seemed to reveal him as a "party" sort of friend, always inviting Cecilia to outings or parties
      - There is A, but also A.P.A. --> same person?
        - A female, APA male
    - Looking at 'went' --> discussion of outings and trips she or a friend had gone on
      - More varied social crowd --> casual friends?
      - At one point she says "Ros called up and I went in to 24 to goose" --> what does 24 to goose mean??? google won't tell me??
    - Looking at 'got' --> mostly used to describe transit or items
      - got ready to go, got off [mode of transport], got to [place]
    - 'good'
      - 'good' usually a measure of quantity --> implies a 'good' amount of something
      - When 'good' used as descriptor it is coupled with either 'very' or 'pretty'
        - As evident from both her use of shorthand, simple sentence structure, and her primary descriptor being good Cecilia either does not care for writing or does not have much of a background in it --> makes me wonder about her education?
  - Cirrus
    - Continues to contribute to image of busy/transient/social lifestyle
    - Largest words include time specifiers and social activities such as 'called' and 'talk'
    - 'lunch' and 'din' (dinner) when looked at in context of a phrase are always mentioned in relation to events or outings with friends
  - Other Observations
    - Most common repeat phrases are about activities with other people
    - When looking at phrases in context, it seems she references well known places in New York so I'm assuming she lived there, with frequent trips to "Phila" and Washington


### Topic Model
- Using R because now I'm VERY comfortable with it after all that webscraping
- Don't have this text in csv...
  - TO DO:
    - Modify or create R script from diary that pulls text into csv format with line/entry/date format
    - Wow Cecilia does not know what day it is --> often has 2 entries for the same day, but different week day
      - No calendar?
    - Actually, no need for script --> can just duplicate the diary, add comma after dates, wrap separated date-text into quotation marks, then add headers and save as csv
      - Dates a bit inconsistently styled --> searching for sure indicators of dates (weekday or month beside number) and replaced by rearranging groups
      - Changing months to full word from abbreviation
      - ```\n~``` to separate entries and mark dates
    - Used Excel to add column sequentially labelling entries AND a column to specify broader months for ease when modelling data over time
- It looks like ggplot plots values alphabetically --> this does not work when using months to observe change over time...
  - UPDATE: it's actually the aggregate function that's setting my variable alphabetically --> tried to solve this on and off for about 2hrs total but I don't think I have enough experience in R to figure this one out
  - Proportions can still be compared over time, just not as conviniently
  - HACKED: I just changed the months from text representation to numerical and now it's ordered
- For finding patterns I'm generating a model with 10 topics --> broader overview of general trends
  - Socialite image maintains --> most topics contain "names" or activities that would involve another person (talk, called, met)
  - A consistent spike is found under a topic with words "din,rest,reading,tired" --> a social introvert?
    - Many other topics also involve the word "rest" or something similar/associated like "sat" or "bed" --> sleeping troubles?
  - Largest spikes in docs 1 and 2 indicate Cecilia enjoys a home-y life
- Topic model for reviewing the year --> more details, minuet chan es and shifts in mood, daily life, health, etc
  - Overall rise in topics related to positive language in the middle of year/summer months
  - Discussion of studio time most significant in August --> downtime to hone skill or important deadline
  - General "upward" trend mid-year includes an increase in fatigue ha
- Including details about a cold or the amount of rest you got seems unusual to include in a personal journal --> many topics included relating to these words
  - Did Cecilia have a balanced life, or one that was so busy that she cherished her times of rest enough to journal about it? If latter, did she choose this lifestyle or was it a result of fame (or something else)?

- Her penchant for introversion yet extensive journalling about a bustling social life perhaps suggests the extra necessities required of a woman in a male dominated industry to be successful. Connections must be made and maintained, and extensive travel was a must.
