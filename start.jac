import os;
import logging;
import datetime;
# import from jac_cloud.core.architype { NodeAnchor }
import from byllm.llm { Model }

glob llm = Model(model_name="groq/llama-3.1-8b-instant");

with entry {
    os.environ["OPEN_API_KEY"] = "PUT KEY HERE";
}

glob logger = logging.getLogger("littleX");

# Define nodes

# Define Edges

# Add Meaning-type LLM

# Define Walkers

# Profile

# Tweets

# Follow

### DO NOT MODIFY BELOW THIS LINE
### Boilerplate code for littleX ###
walker visit_profile {
    can visit_profile with `root entry {
        visit [-->(`?Profile)] else {
            new_profile = here ++> Profile();
            grant(new_profile[0], level=ConnectPerm);
            visit new_profile;
        }
    }
}


walker update_profile (visit_profile) {
    has new_username: str;

    can update_profile with profile entry {
        here.username = self.new_username;
        report here;
    }
}

walker get_profile (visit_profile) {
    can get_profile with profile entry {
        report here;
    }
}
walker load_user_profiles {
    obj __specs__ {
        static has auth: bool = False;
    }
    can load_profiles with `root entry {
        self.profiles: list = [];
        
        for user in NodeAnchor.Collection.find({"name": "profile"}) {
            user_node = user.architype;
            self.profiles.append(
                {"name": user_node.username, "id": jid(user_node)}
            );
        }
        report self.profiles;
    }
}


walker un_follow_request {
    can un_follow_request with Profile entry {
        current_profile = [root --> (`?Profile)];
        follow_edge = [edge current_profile[0] ->:Follow:-> self];
        del follow_edge[0];  # Proper deletion of the Follow edge
        report self;
    }
}

walker update_tweet (visit_profile) {
    has tweet_id: str;
    has updated_content: str;

    can visit_tweet with profile entry {
        tweet_node = &self.tweet_id;
        visit tweet_node;
        logger.info(f"Tweet deleted: {tweet_node}");
    }
    # can be enhanced to directly use the jid instead
    can update_tweet with tweet entry {
        here.content = self.updated_content;
        report here;
    }
}

walker remove_tweet (visit_profile) {
    has tweet_id: str;

    can remove_tweet with profile entry {
        tweet_node = &self.tweet_id;
        del tweet_node;
        logger.info(f"Tweet deleted: {tweet_node}");
        report True;
    }
}
