import { useState } from "react";

export default function FeedSection() {
  const [activeTab, setActiveTab] = useState("posts");

  return (
    <section className="flex flex-col gap-4 w-2/4">
      <div className="flex gap-2">
        <button
          className={`p-2 rounded-lg border text-center w-fit cursor-pointer hover:bg-slate-800 transition-all 
            duration-100 active:scale-95 flex items-center gap-2 ${
              activeTab === "posts"
                ? "bg-slate-700 border-cyan-800"
                : "bg-slate-950"
            }`}
          onClick={() => setActiveTab("posts")}
        >
          <p>Posts</p>
        </button>
        <button
          className={`p-2 rounded-lg border text-center w-fit cursor-pointer hover:bg-slate-800 transition-all 
            duration-100 active:scale-95 flex items-center gap-2 ${
              activeTab === "projects"
                ? "bg-slate-700 border-cyan-800"
                : "bg-slate-950"
            }`}
          onClick={() => setActiveTab("projects")}
        >
          <p>Projects</p>
        </button>
      </div>

      {activeTab === "posts" && (
        <div className="bg-slate-950 p-4 rounded-lg border flex flex-col gap-4">
          <div className="flex gap-4">
            <div className="rounded-full border w-12 h-12 bg-slate-800"></div>
            <div className="flex flex-col">
              <p className="text-lg">Username</p>
              <p className="text-sm text-gray-400">10/10/2024</p>
            </div>
          </div>
          <div className="flex flex-col gap-2">
            <p className="text-lg">Post Title</p>
            <p className="text-md text-gray-400">
              Post Description. Lorem ipsum dolor sit amet consectetur
              adipisicing elit. Quisquam, quos. Lorem ipsum dolor sit amet
              consectetur adipisicing elit. Quisquam, quos. Lorem ipsum dolor
              sit amet consectetur adipisicing elit. Quisquam, quos.
            </p>
          </div>
        </div>
      )}

      {activeTab === "projects" && (
        <div className="bg-slate-950 p-4 rounded-lg border flex flex-col gap-4">
          <div className="flex gap-4">
            <div className="rounded-full border w-12 h-12 bg-slate-800"></div>
            <div className="flex flex-col">
              <p className="text-lg">Username</p>
              <p className="text-sm text-gray-400">10/10/2024</p>
            </div>
          </div>
          <div className="flex flex-col gap-2">
            <p className="text-lg">Project Title</p>
            <p className="text-md text-gray-400">
              Project Description. Lorem ipsum dolor sit amet consectetur
              adipisicing elit. Quisquam, quos. Lorem ipsum dolor sit amet
              consectetur adipisicing elit. Quisquam, quos. Lorem ipsum dolor
              sit amet consectetur adipisicing elit. Quisquam, quos.
            </p>
          </div>
        </div>
      )}
    </section>
  );
}
