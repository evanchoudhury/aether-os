import "@designcodeio/threeui/style.css";
import { KiboriLandingPage } from "./shaders/kibori-landing-page/KiboriLandingPage";
import "./App.css";

// Real Kibori (木彫), shipped verbatim. The package @designcodeio/threeui@1.2.0
// does not export KiboriLandingPage, so we use the spec's component source
// locally. It loads the canonical /landing-pages/kibori.html from this app's
// own origin (public/), as the integration spec requires.
export default function App() {
  return (
    <div className="shader-frame">
      <KiboriLandingPage />
    </div>
  );
}
