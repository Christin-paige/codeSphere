import Projects from "./projects/ProjectList";
import FriendsProjects from "./friends-projects/FriendsProjects";
import Stats from "./stats/Stats";
import Feed from "./feed/Feed";
import Profile from "./profile/Profile";
import Groups from "./groups/Groups";

export default async function Dashboard() {
  return (
    <div className="grid grid-cols-1 lg:grid-cols-6 gap-3 pt-45 p-4 overflow-hidden bg-gray-900 text-white">
      <div className=" row-span-1 row-start-1 flex flex-col overflow-auto">
        <Profile />
      </div>

      <div className="row-span-3 row-start-2 flex flex-col overflow-auto">
        <Projects />
      </div>

      <div className="col-span-4 flex flex-col overflow-auto">
        <FriendsProjects />
      </div>

      <div className="col-span-1 overflow-auto">
        <Stats />
      </div>

      <div className="col-span-1 col-start-6 overflow-auto">
        <Groups />
      </div>

      <div className="lg:col-start-2 lg:col-span-4 row-start-2 flex flex-col h-[650px] overflow-auto">
        <Feed />
      </div>
    </div>
  );
}
