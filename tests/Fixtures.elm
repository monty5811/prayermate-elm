module Fixtures exposing (..)


test_data : String
test_data =
    """{"Categories": [{"name": "Biblical Prayers", "createdDate": "2017-09-27T16:29", "itemsPerSession": 1, "visible": true, "pinned": false, "manualSessionLimit": null, "syncID": "c+DBABA9E8EEA91DE13FACA7CD13BA9E26|+1", "subjects": [{"name": "The Lord's Prayer", "createdDate": "2017-09-27T16:29", "syncID": "s+D62D437EC3629D9EC1D0A1E01E958A3A|+1", "priorityLevel": 0, "seenCount": 0, "cards": [{"text": "Our Father, who is in heaven,\\nhallowed be your name;\\nyour kingdom come;\\nyour will be done,\\non earth as it is in heaven.\\nGive us this day our daily bread.\\nAnd forgive us our trespasses,\\nas we forgive those that trespass against us.\\nLead us not into temptation;\\nbut deliver us from evil.\\nFor yours is the kingdom,\\nthe power, and the glory,\\nfor ever and ever.\\nAmen.", "archived": false, "syncID": "k+D62D437EC3629D9EC1D0A1E01E958A3A|+1+0", "createdDate": "2017-09-27T16:29", "dayOfTheWeekMask": 0, "schedulingMode": 0, "seenCount": 0}]}, {"name": "Matthew 9:38", "createdDate": "2017-09-27T16:29", "syncID": "s+6DCB59CA2B43C5BF3CD05D5EE4C9A0E|+1", "priorityLevel": 0, "seenCount": 0, "cards": [{"text": "The Harvest is plentiful but the labourers are few; therefore pray earnestly to the Lord of the harvest to send out labourers into his harvest. (English Standard Version)", "archived": false, "syncID": "k+6DCB59CA2B43C5BF3CD05D5EE4C9A0E|+1+0", "createdDate": "2017-09-27T16:29", "dayOfTheWeekMask": 0, "schedulingMode": 0, "seenCount": 0}]}]}, {"name": "My Walk With God", "createdDate": "2017-09-27T16:29", "itemsPerSession": 1, "visible": true, "pinned": false, "manualSessionLimit": null, "syncID": "c+88AEA013C2BDD89539A3D6CE2922411F|+1", "subjects": [{"name": "Growing more like Jesus", "createdDate": "2017-09-27T16:29", "syncID": "s+9B62C8E395549FA69FF0709480C2CC2A|+1", "priorityLevel": 0, "seenCount": 0, "cards": [{"text": "PrayerMate tip: press the pencil icon to edit this text, or to rename the subject.\\n\\nPray I will 'be filled with the knowledge of God's will in all spiritual wisdom and understanding, so as to walk in a manner worthy of the Lord, fully pleasing to him, bearing fruit in every good work and increasing in the knowledge of God.'\\n\\nMay God strengthen me 'with all power, according to his glorious might, for all endurance and patience with joy, giving thanks to the Father, who has qualified me to share in the inheritance of the saints in light.' Colossians 1:9-12, English Standard Version)", "archived": false, "syncID": "k+9B62C8E395549FA69FF0709480C2CC2A|+1+0", "createdDate": "2017-09-27T16:29", "dayOfTheWeekMask": 0, "schedulingMode": 0, "seenCount": 0}]}]}, {"name": "My Family", "createdDate": "2017-09-27T16:29", "itemsPerSession": 1, "visible": true, "pinned": false, "manualSessionLimit": null, "syncID": "c+8004C0EDE919F6FC8D092ACE36D7E704|+1", "subjects": []}, {"name": "My Church", "createdDate": "2017-09-27T16:29", "itemsPerSession": 1, "visible": true, "pinned": false, "manualSessionLimit": null, "syncID": "c+57000ED5891078CC624603C5745D8318|+1", "subjects": []}, {"name": "Unbelievers", "createdDate": "2017-09-27T16:29", "itemsPerSession": 1, "visible": true, "pinned": false, "manualSessionLimit": null, "syncID": "c+A77065B0D4D6680D41965FD1F909EE31|+1", "subjects": []}, {"name": "World Mission", "createdDate": "2017-09-27T16:29", "itemsPerSession": 1, "visible": true, "pinned": false, "manualSessionLimit": null, "syncID": "c+92ED76C1D9B50290AB27F5A9B467B7AF|+1", "subjects": []}], "Feeds": [{"name": "Open Doors UK", "subscribedAt": "2017-09-27T16:29", "SyncID": "httpsprayermates3amazonawscomfeed9json", "image": "https://s3-eu-west-1.amazonaws.com/prayermate-static/open_doors_logo.jpeg", "url": "https://prayermate.s3.amazonaws.com/feed_9.json", "category": "World Mission"}], "PrayerMateAndroidVersion": "5.9.5.0"}"""


test_data_csv : String
test_data_csv =
    """"Biblical Prayers","The Lord's Prayer","Our Father, who is in heaven,
hallowed be your name;
your kingdom come;
your will be done,
on earth as it is in heaven.
Give us this day our daily bread.
And forgive us our trespasses,
as we forgive those that trespass against us.
Lead us not into temptation;
but deliver us from evil.
For yours is the kingdom,
the power, and the glory,
for ever and ever.
Amen."
"Biblical Prayers","Matthew 9:38","The Harvest is plentiful but the labourers are few; therefore pray earnestly to the Lord of the harvest to send out labourers into his harvest. (English Standard Version)"
"My Walk With God","Growing more like Jesus","PrayerMate tip: press the pencil icon to edit this text, or to rename the subject.

Pray I will 'be filled with the knowledge of God's will in all spiritual wisdom and understanding, so as to walk in a manner worthy of the Lord, fully pleasing to him, bearing fruit in every good work and increasing in the knowledge of God.'

May God strengthen me 'with all power, according to his glorious might, for all endurance and patience with joy, giving thanks to the Father, who has qualified me to share in the inheritance of the saints in light.' Colossians 1:9-12, English Standard Version)"
"""


test_data_ios : String
test_data_ios =
    """{"Categories": [{"pinned": false, "name": "Biblical Prayers", "createdDate": "2017-09-12T17:55", "syncID": "c+DBABA9E8EEA91DE13FACA7CD13BA9E26|+1", "visible": true, "subjects": [{"cards": [{"syncID": "k+D62D437EC3629D9EC1D0A1E01E958A3A|+1+0", "archived": false, "createdDate": "2017-09-12T17:55", "dayOfTheWeekMask": 0, "seenCount": 0, "text": "Our Father, who is in heaven,\\nhallowed be your name;\\nyour kingdom come;\\nyour will be done,\\non earth as it is in heaven.\\nGive us this day our daily bread.\\nAnd forgive us our sins,\\nas we forgive those that sin against us.\\nLead us not into temptation;\\nbut deliver us from evil.\\nFor yours is the kingdom,\\nthe power, and the glory,\\nfor ever and ever.\\nAmen.", "schedulingMode": 0}], "createdDate": "2017-09-12T17:55", "seenCount": 0, "name": "The Lord's Prayer", "syncID": "s+D62D437EC3629D9EC1D0A1E01E958A3A|+1", "priorityLevel": 0}, {"cards": [{"syncID": "k+06DCB59CA2B43C5BF3CD05D5EE4C9A0E|+1+0", "archived": false, "createdDate": "2017-09-12T17:55", "dayOfTheWeekMask": 0, "seenCount": 0, "text": "The harvest is plentiful but the labourers are few; therefore pray earnestly to the Lord of the harvest to send out labourers into his harvest.\\n(English Standard Version)", "schedulingMode": 0}], "createdDate": "2017-09-12T17:55", "seenCount": 0, "name": "Matthew 9:38", "syncID": "s+06DCB59CA2B43C5BF3CD05D5EE4C9A0E|+1", "priorityLevel": 0}], "manualSessionLimit": null, "itemsPerSession": 1}, {"pinned": false, "name": "My Walk With God", "createdDate": "2017-09-12T17:55", "syncID": "c+88AEA013C2BDD89539A3D6CE2922411F|+1", "visible": true, "subjects": [{"cards": [{"syncID": "k+9B62C8E395549FA69FF0709480C2CC2A|+1+0", "archived": false, "createdDate": "2017-09-12T17:55", "dayOfTheWeekMask": 0, "seenCount": 0, "text": "PrayerMate tip: press the pencil icon to edit this text, or to rename the subject.\\n\\nPray I will 'be filled with the knowledge of God's will in all spiritual wisdom and understanding, so as to walk in a manner worthy of the Lord, fully pleasing to him, bearing fruit in every good work and increasing in the knowledge of God.'\\n\\nMay God strengthen me 'with all power, according to his glorious might, for all endurance and patience with joy, giving thanks to the Father, who has qualified me to share in the inheritance of the saints in light.' (Colossians 1:9-12, English Standard Version)", "schedulingMode": 0}], "createdDate": "2017-09-12T17:55", "seenCount": 0, "name": "Growing more like Jesus", "syncID": "s+9B62C8E395549FA69FF0709480C2CC2A|+1", "priorityLevel": 0}], "manualSessionLimit": null, "itemsPerSession": 1}, {"pinned": false, "name": "My Family", "createdDate": "2017-09-12T17:55", "syncID": "c+8004C0EDE919F6FC8D092ACE36D7E704|+1", "visible": true, "subjects": [{"cards": [{"syncID": "89D36D77EB774C7D8534C8F312F107B9", "archived": false, "createdDate": "2017-09-12T17:56", "dayOfTheWeekMask": 0, "seenCount": 0, "text": "", "schedulingMode": 0}], "createdDate": "2017-09-12T17:56", "seenCount": 0, "name": "Andy", "syncID": "A6831619BF5541E9B1A60CC35320D744", "priorityLevel": 0}, {"cards": [{"syncID": "098FD710C04F47C3BD58B78D5AA6AB43", "archived": false, "createdDate": "2017-09-12T17:56", "dayOfTheWeekMask": 0, "seenCount": 0, "text": "", "schedulingMode": 0}], "createdDate": "2017-09-12T17:56", "seenCount": 0, "name": "Elise", "syncID": "DEFAEFE5C1674697B3DF852B78D2F974", "priorityLevel": 0}, {"cards": [{"syncID": "1AD897FE7FBA47C9918CE94239533D70", "archived": false, "createdDate": "2017-09-12T17:56", "dayOfTheWeekMask": 0, "seenCount": 0, "text": "Pray for Isambard to enjoy starting school and make really good friends. Dear God, please may Isambard grow up in to a godly man who loves Jesus.", "schedulingMode": 0}], "createdDate": "2017-09-12T17:56", "seenCount": 0, "name": "Isambard", "syncID": "331C040151FD428287A2E8CB8D4E46A5", "priorityLevel": 0}, {"cards": [{"syncID": "526EC55382CA40059FFD180E39F41CFD", "archived": false, "createdDate": "2017-09-12T17:56", "dayOfTheWeekMask": 0, "seenCount": 0, "text": "", "schedulingMode": 0}], "createdDate": "2017-09-12T17:56", "seenCount": 0, "name": "Oriana", "syncID": "7560C2FFCFDD4661BFB3E2516C2D1D4D", "priorityLevel": 0}, {"cards": [{"syncID": "121D205F93194BC2851EDBBBBE6A9EB1", "archived": false, "createdDate": "2017-09-12T17:56", "dayOfTheWeekMask": 0, "seenCount": 0, "text": "", "schedulingMode": 0}], "createdDate": "2017-09-12T17:56", "seenCount": 0, "name": "Uzziah", "syncID": "D5DB98B34D2540C783632D11997AE275", "priorityLevel": 0}], "manualSessionLimit": null, "itemsPerSession": 1}, {"pinned": false, "name": "My Church", "createdDate": "2017-09-12T17:55", "syncID": "c+57000ED5891078CC624603C5745D8318|+1", "visible": true, "subjects": [], "manualSessionLimit": null, "itemsPerSession": 1}, {"pinned": false, "name": "Unbelievers", "createdDate": "2017-09-12T17:55", "syncID": "c+A77065B0D4D6680D41965FD1F909EE31|+1", "visible": true, "subjects": [], "manualSessionLimit": null, "itemsPerSession": 1}, {"pinned": false, "name": "World Mission", "createdDate": "2017-09-12T17:55", "syncID": "c+92ED76C1D9B50290AB27F5A9B467B7AF|+1", "visible": true, "subjects": [], "manualSessionLimit": null, "itemsPerSession": 1}, {"pinned": false, "name": "Archive", "createdDate": "2017-09-12T17:55", "syncID": "|||+_archive_+|||", "visible": false, "subjects": [], "manualSessionLimit": null, "itemsPerSession": 0}], "Feeds": [{"category": "World Mission", "syncID": "httpsprayermates3amazonawscomf177274cde2d7063e38e03d24bed2f3769c0json", "image": "http://prayermate.s3.amazonaws.com/prayer_diaries/logo_images/000/000/267/original/opendoorsusa.jpeg", "subscribedAt": "2017-09-12T17:55", "description": "For almost 60 years, Open Doors has worked in the world's most oppressive countries, empowering Christians who are persecuted for their beliefs. Open Doors equips persecuted Christians in more than 60 countries through programs like Bible & Gospel Development, Women & Children Advancement and Christian Community Restoration.", "name": "Open Doors USA", "url": "https://prayermate.s3.amazonaws.com/f177274cde2d7063e38e03d24bed2f3769c0.json"}], "PrayerMateVersion": "5.10.0"}"""


test_data_ios_csv : String
test_data_ios_csv =
    """"Biblical Prayers","The Lord's Prayer","Our Father, who is in heaven,
hallowed be your name;
your kingdom come;
your will be done,
on earth as it is in heaven.
Give us this day our daily bread.
And forgive us our sins,
as we forgive those that sin against us.
Lead us not into temptation;
but deliver us from evil.
For yours is the kingdom,
the power, and the glory,
for ever and ever.
Amen."
"Biblical Prayers","Matthew 9:38","The harvest is plentiful but the labourers are few; therefore pray earnestly to the Lord of the harvest to send out labourers into his harvest.
(English Standard Version)"
"My Walk With God","Growing more like Jesus","PrayerMate tip: press the pencil icon to edit this text, or to rename the subject.

Pray I will 'be filled with the knowledge of God's will in all spiritual wisdom and understanding, so as to walk in a manner worthy of the Lord, fully pleasing to him, bearing fruit in every good work and increasing in the knowledge of God.'

May God strengthen me 'with all power, according to his glorious might, for all endurance and patience with joy, giving thanks to the Father, who has qualified me to share in the inheritance of the saints in light.' (Colossians 1:9-12, English Standard Version)"
"My Family","Andy",""
"My Family","Elise",""
"My Family","Isambard","Pray for Isambard to enjoy starting school and make really good friends. Dear God, please may Isambard grow up in to a godly man who loves Jesus."
"My Family","Oriana",""
"My Family","Uzziah",""
"""
