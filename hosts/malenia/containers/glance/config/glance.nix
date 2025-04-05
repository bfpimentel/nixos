{
  pages = [
    {
      name = "bruno's lab";
      columns = [
        {
          size = "small";
          widgets = [
            {
              type = "calendar";
              first-day-of-week = "monday";
            }
            {
              type = "rss";
              limit = 10;
              collapse-after = 3;
              cache = "12h";
              feeds = [
                {
                  url = "https://selfh.st/rss/";
                  title = "selfh.st";
                  limit = 4;
                }
                {
                  url = "https://ciechanow.ski/atom.xml";
                }
                {
                  url = "https://www.joshwcomeau.com/rss.xml";
                  title = "Josh Comeau";
                }
                { url = "https://samwho.dev/rss.xml"; }
                {
                  url = "https://ishadeed.com/feed.xml";
                  title = "Ahmad Shadeed";
                }
              ];
            }
            {
              type = "twitch-channels";
              channels = [
                "theprimeagen"
                "j_blow"
                "piratesoftware"
                "cohhcarnage"
                "christitustech"
                "EJ_SA"
              ];
            }
          ];
        }
        {
          size = "full";
          widgets = [
            {
              type = "group";
              widgets = [
                { type = "hacker-news"; }
                { type = "lobsters"; }
              ];
            }
            {
              type = "docker-containers";
              hide-by-default = false;
            }
            {
              type = "group";
              widgets = [
                {
                  type = "reddit";
                  subreddit = "technology";
                  show-thumbnails = true;
                }
                {
                  type = "reddit";
                  subreddit = "selfhosted";
                  show-thumbnails = true;
                }
              ];
            }
          ];
        }
        {
          size = "small";
          widgets = [
            {
              type = "weather";
              location = "London, United Kingdom";
              units = "metric";
              hour-format = "12h";
            }
            {
              type = "markets";
              markets = [
                {
                  symbol = "SPY";
                  name = "S&P 500";
                }
                {
                  symbol = "BTC-USD";
                  name = "Bitcoin";
                }
                {
                  symbol = "NVDA";
                  name = "NVIDIA";
                }
                {
                  symbol = "AAPL";
                  name = "Apple";
                }
                {
                  symbol = "MSFT";
                  name = "Microsoft";
                }
              ];
            }
            {
              type = "releases";
              cache = "1d";
              repositories = [
                "glanceapp/glance"
                "go-gitea/gitea"
                "immich-app/immich"
                "syncthing/syncthing"
              ];
            }
          ];
        }
      ];
    }
  ];
}
