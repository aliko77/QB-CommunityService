# QB-CommunityService
Community service for QB, Similar to ESX version

### Requirements
- QB
- okokTextUI
- qb-clothing

### Installation
- Import database.sql in your database
- Add this in your server.cfg : start nmr_communityservice

### F3 Menu integrated
```
  {
    id    = 'communityservice',
    title = 'Kamu Cezası',
    icon = '#general',
    type = 'client',
    event = 'communityservice:client:AddCommunityService',
    shouldClose = true,
  },
```
