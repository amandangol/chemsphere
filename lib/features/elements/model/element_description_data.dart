// Static data for element descriptions and discovery information
// Used to supplement the data from the PubChem API

class ElementDescriptionData {
  // Map of element symbols to their descriptions
  static Map<String, String> descriptions = {
    'H':
        'Hydrogen is the lightest and most abundant chemical element in the universe. It is primarily used in fossil fuel processing, ammonia production for fertilizers, and as a potential clean fuel source.',
    'He':
        'Helium is an inert noble gas found in natural gas deposits. It\'s used in cryogenics, pressurizing rocket fuel, and in balloons due to its lightness and non-flammability.',
    'Li':
        'Lithium is the lightest metal and is highly reactive. It\'s primarily used in rechargeable batteries, but also in ceramics, glass, and pharmaceuticals for treating bipolar disorder.',
    'Be':
        'Beryllium is a rare earth metal with high thermal conductivity. It\'s used in aerospace components, X-ray tubes, and nuclear reactors due to its strength and light weight.',
    'B':
        'Boron is a metalloid that rarely occurs in nature. It\'s used in borosilicate glass, detergents, and as a dopant in semiconductors for electronics.',
    'C':
        'Carbon forms the basis of organic chemistry and all known life. It exists in various allotropic forms and is used in steelmaking, as graphite in pencils, and as diamond in cutting tools.',
    'N':
        'Nitrogen is a colorless, odorless gas that makes up about 78% of Earth\'s atmosphere. It\'s used in fertilizers, explosives manufacturing, and as a coolant in food freezing.',
    'O':
        'Oxygen is essential for respiration in most living organisms. It makes up 21% of Earth\'s atmosphere and is used in steel production, medical applications, and rocket propellants.',
    'F':
        'Fluorine is the most electronegative element and highly reactive. It\'s used in toothpaste, non-stick coatings (Teflon), refrigerants, and uranium processing.',
    'Ne':
        'Neon is an inert noble gas used primarily in illuminated signs. It produces a distinctive reddish-orange glow when used in electric discharge tubes.',
    'Na':
        'Sodium is a highly reactive alkali metal. It\'s used in sodium vapor lamps, as table salt (sodium chloride), and in many chemical processes as a reducing agent.',
    'Mg':
        'Magnesium is a lightweight metal used in alloys for aircraft and automotive components. It\'s also essential for photosynthesis and human nutrition.',
    'Al':
        'Aluminum is the most abundant metal in Earth\'s crust. It\'s used in transportation, packaging, construction, and electrical transmission lines due to its light weight and corrosion resistance.',
    'Si':
        'Silicon is a metalloid essential to the modern electronics industry. It\'s used in semiconductors, solar cells, and as silica in glass and cement production.',
    'P':
        'Phosphorus is essential for life, found in DNA and ATP. It\'s used in fertilizers, detergents, and matches, and some compounds are used as flame retardants.',
    'S':
        'Sulfur is used in fertilizers, gunpowder, and vulcanization of rubber. It\'s also a component of many proteins and is released in volcanic eruptions.',
    'Cl':
        'Chlorine is used in water purification, bleaches, and the production of many industrial products. It\'s highly reactive and exists as a yellowish-green gas at room temperature.',
    'Ar':
        'Argon is an inert noble gas used in light bulbs, welding, and as a protective atmosphere in various industrial processes due to its non-reactivity.',
    'K':
        'Potassium is essential for plant and animal life. It\'s used in fertilizers and is a fundamental part of the sodium-potassium pump in cell membranes.',
    'Ca':
        'Calcium is vital for bone formation, cellular processes, and blood clotting. Industrially, it\'s used in cement, mortars, and as a reducing agent.',
    'Fe':
        'Iron is the most common element on Earth by mass. It\'s essential for hemoglobin in blood, and it\'s the primary component of steel used in construction and manufacturing.',
    'Cu':
        'Copper has excellent thermal and electrical conductivity. It\'s used in electrical wiring, plumbing, and as an architectural metal, with a distinctive reddish color.',
    'Ag':
        'Silver has the highest electrical conductivity of any element. It\'s used in photography, jewelry, electronics, and as a currency metal throughout history.',
    'Au':
        'Gold is prized for its beauty, rarity, and resistance to corrosion. It\'s used in jewelry, electronics, dentistry, and as a global monetary standard.',
    'Hg':
        'Mercury is the only metal that is liquid at room temperature. Historically used in thermometers and switches, its use is now restricted due to toxicity concerns.',
    'Pb':
        'Lead is a dense, soft metal historically used in plumbing, bullets, and paints. Its use has been restricted due to its toxic properties, especially to neurological development.',
    'U':
        'Uranium is primarily used as fuel in nuclear power plants. It\'s a dense metal with radioactive isotopes that can undergo nuclear fission, releasing enormous energy.',
    'Sc':
        'Scandium is a rare earth metal that\'s soft and silvery when pure. It\'s primarily used in aerospace components, sports equipment, and high-intensity lights due to its strength-to-weight ratio and heat resistance.',
    'Ti':
        'Titanium is a strong, lightweight, corrosion-resistant metal. It\'s used in aerospace engineering, medical implants, sports equipment, and jewelry due to its exceptional strength-to-weight ratio.',
    'V':
        'Vanadium is a hard, silvery-gray metal primarily used as an additive in steel alloys to increase strength and corrosion resistance. It\'s also used in nuclear applications and vanadium redox batteries.',
    'Cr':
        'Chromium is a hard, silvery metal known for its corrosion resistance. It\'s used in stainless steel production, electroplating for decorative finishes, and in superalloys for high-temperature applications.',
    'Mn':
        'Manganese is essential in steel production where it improves workability and strength. It\'s also used in aluminum alloys, batteries, and as a pigment. In trace amounts, it\'s a crucial nutrient for plants and animals.',
    'Co':
        'Cobalt is a hard, lustrous metal essential for many high-strength alloys and magnetic materials. It\'s crucial in lithium-ion batteries, superalloys for jet engines, and historically as a blue pigment in ceramics and glass.',
    'Ni':
        'Nickel is a silvery-white metal valued for its corrosion resistance and ability to withstand high temperatures. It\'s extensively used in stainless steel, coins, rechargeable batteries, and catalysts.',
    'Zn':
        'Zinc is a bluish-white metal used primarily for galvanizing steel against corrosion. It\'s also used in brass alloys, batteries, and as a dietary supplement due to its importance in biological processes.',
    'Ga':
        'Gallium is a soft, silvery metal that can melt in your hand at 85.6°F (29.8°C). It\'s used in semiconductors, LEDs, solar panels, and high-temperature thermometers.',
    'Ge':
        'Germanium is a lustrous, hard-brittle metalloid used in fiber optics, infrared optics, solar cell applications, and as a semiconductor. It was crucial in the development of the first transistor.',
    'As':
        'Arsenic is a metalloid that\'s notorious for its toxicity. It\'s used in wood preservatives, semiconductor manufacturing (particularly in gallium arsenide for LEDs), and some specialized glass production.',
    'Se':
        'Selenium is a non-metal essential in small amounts for cellular function in many organisms. It\'s used in electronics, glass production, anti-dandruff shampoos, and as a supplement for livestock and humans.',
    'Br':
        'Bromine is a reddish-brown liquid at room temperature with a strong odor. It\'s used in flame retardants, water purification, agricultural chemicals, and formerly in leaded gasoline additives.',
    'Kr':
        'Krypton is an inert noble gas used in high-powered photographic flashes, specialized lighting, and as a filling gas in energy-efficient windows. It glows pale yellow-green in electric discharge tubes.',

    // Period 4 and beyond (selected important elements)
    'Rb':
        'Rubidium is a soft, highly reactive metal similar to potassium. It\'s used in atomic clocks, vacuum tubes, photocells, and as a getter in vacuum tubes to remove trace gases.',
    'Sr':
        'Strontium is a soft silver-white metal similar to calcium. It\'s used in pyrotechnics for crimson colors in fireworks, in certain ceramics, and strontium-90 isotope is used in radioisotope thermoelectric generators.',
    'Y':
        'Yttrium is a silvery-metallic transition metal used in LED and OLED manufacturing, camera lenses, and as an additive in alloys. It\'s also used in some cancer treatments via radiation therapy.',
    'Zr':
        'Zirconium is a strong, corrosion-resistant metal primarily used in nuclear reactors due to its low neutron absorption. It\'s also used in ceramics, strong alloys, and artificial joints and implants.',
    'Nb':
        'Niobium is a soft, gray, ductile metal used in steel alloys to increase strength and corrosion resistance. It\'s essential in superconducting magnets and is used in jewelry and commemorative coins.',
    'Mo':
        'Molybdenum is a refractory metal with one of the highest melting points. It\'s used in high-strength steel alloys, electrical contacts, and as a catalyst in petroleum refining.',
    'Tc':
        'Technetium is the lightest radioactive element with no stable isotopes. It\'s used primarily in nuclear medicine for diagnostic imaging procedures, with no significant industrial applications due to its radioactivity.',
    'Ru':
        'Ruthenium is a rare platinum group metal that\'s hard and brittle. It\'s used as a catalyst, in electrical contacts, and to harden platinum and palladium alloys used in jewelry.',
    'Rh':
        'Rhodium is a rare, silvery-white metal known for its reflectivity and corrosion resistance. It\'s primarily used in catalytic converters for automobiles and as a finish for jewelry and mirrors.',
    'Pd':
        'Palladium is a precious metal resembling platinum. It\'s crucial in catalytic converters, electronics, dental work, and as a catalyst in chemical reactions, particularly hydrogenation processes.',
    'Cd':
        'Cadmium is a soft, bluish-white metal primarily used in rechargeable nickel-cadmium batteries. Its use has declined due to toxicity concerns, but it\'s still used in some alloys and as a neutron absorber in nuclear reactors.',
    'In':
        'Indium is a soft, malleable metal crucial in the production of transparent conductive coatings for touchscreens and LCD displays. It\'s also used in semiconductors and low-melting-point alloys.',
    'Sn':
        'Tin is a silvery metal that resists corrosion and is used in solder, tinplate (tin-coated steel for food containers), bronze, and pewter. It has been used since ancient times in various alloys.',
    'Sb':
        'Antimony is a lustrous gray metalloid used in flame retardants, batteries, and as an alloying agent. It improves the hardness and mechanical strength of lead and is used in semiconductors.',
    'Te':
        'Tellurium is a brittle, mildly toxic, rare metalloid. It\'s primarily used in alloys, solar panels, and as a semiconductor in thermoelectric devices that convert heat to electricity.',
    'I':
        'Iodine is a lustrous purple-black non-metal that sublimes at standard conditions. It\'s essential for thyroid function in humans and is used as a disinfectant, in photography, and in certain medications.',
    'Xe':
        'Xenon is an inert noble gas used in specialized lighting including camera flashes and arc lamps. It\'s also used in medical imaging, as an anesthetic, and in ion propulsion systems for spacecraft.',
    'Cs':
        'Cesium is an extremely reactive alkali metal that\'s liquid near room temperature. It\'s used in atomic clocks, as a catalyst promoter, in vacuum tubes, and in radiation monitoring equipment.',
    'Ba':
        'Barium is a soft, silvery alkaline earth metal. It\'s used in drilling fluids for oil wells, in paint, bricks, cement, glass, and barium meals for medical diagnostic imaging of the digestive system.',
    'La':
        'Lanthanum is a soft, malleable rare earth metal. It\'s used in hybrid car batteries, high-refractive-index glass for camera lenses, studio lighting, and as a catalyst in petroleum refining.',
    'Ce':
        'Cerium is the most abundant rare earth metal. It\'s used in catalytic converters, as a polishing agent for glass, in self-cleaning ovens, and as an alloying agent to create lighter flints.',
    'Pt':
        'Platinum is a dense, malleable precious metal known for its resistance to corrosion. It\'s used in catalytic converters, laboratory equipment, electrical contacts, jewelry, and anticancer drugs.',
    'W':
        'Tungsten has the highest melting point of all metals. It\'s used in light bulb filaments, welding electrodes, heating elements, and armor-piercing ammunition due to its hardness and heat resistance.',
    'Os':
        'Osmium is one of the densest elements and belongs to the platinum group. It\'s used in electrical contacts, fountain pen tips, and instrument pivots where extreme hardness and durability are required.',
    'Ir':
        'Iridium is one of the rarest elements in Earth\'s crust and the most corrosion-resistant metal. It\'s used in spark plugs, crucibles, and the international prototype kilogram was made of an iridium-platinum alloy.',
    'Tl':
        'Thallium is a soft, malleable metal with high toxicity. Despite its dangers, it\'s used in specialized electronics, medical imaging, and historically was used in rat poisons and insecticides.',
    'Bi':
        'Bismuth is a brittle metal with a pinkish hue. It expands when it solidifies and is used in pharmaceuticals, cosmetics, low-melting alloys, and as a replacement for lead in various applications.',
    'Po':
        'Polonium is a rare and highly radioactive metal discovered by Marie Curie. It has few applications outside research but has been used in anti-static brushes and as a heat source in spacecraft.',
    'Rn':
        'Radon is a radioactive noble gas that occurs naturally from the decay of radium. It has limited uses due to its radioactivity but is used in some forms of radiation therapy and geological research.',
    'Fr':
        'Francium is an extremely rare and highly radioactive alkali metal. It has no significant commercial or practical applications due to its scarcity and short half-life.',
    'Ra':
        'Radium is a radioactive alkaline earth metal discovered by Marie and Pierre Curie. Historically used in luminous paint and supposed health products, its use is now limited due to recognized radiation hazards.',
    'Ac':
        'Actinium is a radioactive element that glows in the dark due to its intense radioactivity. It has limited applications primarily in research and potentially as a neutron source in medicine.',
    'Th':
        'Thorium is a radioactive metal that has been used as a nuclear fuel alternative to uranium. It\'s also used in high-quality lenses, welding electrodes, and historically in gas mantles for lamps.',
    'Pa':
        'Protactinium is a radioactive, silvery metal that has no significant commercial applications. It\'s primarily used in scientific research and is an intermediate product in thorium fuel cycles.',
    'Np':
        'Neptunium is a radioactive actinide metal and was the first synthetic transuranium element produced. It has limited uses mainly in nuclear detection equipment and as a component in neutron detection devices.',
    'Pu':
        'Plutonium is a radioactive metal primarily used in nuclear weapons and as fuel in nuclear power reactors. Plutonium-238 is used to power spacecraft in radioisotope thermoelectric generators.',
    'Am':
        'Americium is a synthetic radioactive metal primarily used in smoke detectors (americium-241) where its radiation ionizes air to detect smoke particles. It\'s also used in measuring equipment and medical devices.',
  };

  // Map of element symbols to their discovery information
  static const Map<String, Map<String, String>> discoveryInfo = {
    'H': {
      'discoveredBy': 'Henry Cavendish',
      'namedBy': 'Antoine Lavoisier',
      'year': '1766',
    },
    'He': {
      'discoveredBy': 'Pierre Janssen, Norman Lockyer',
      'namedBy': 'From Greek "helios" (sun)',
      'year': '1868',
    },
    'Li': {
      'discoveredBy': 'Johan August Arfwedson',
      'namedBy': 'From Greek "lithos" (stone)',
      'year': '1817',
    },
    'Be': {
      'discoveredBy': 'Louis-Nicolas Vauquelin',
      'namedBy': 'From the mineral beryl',
      'year': '1798',
    },
    'B': {
      'discoveredBy': 'Joseph Louis Gay-Lussac, Louis Jacques Thénard',
      'namedBy': 'From Arabic "buraq" and Persian "burah"',
      'year': '1808',
    },
    'C': {
      'discoveredBy': 'Known to antiquity',
      'namedBy': 'From Latin "carbo" (charcoal)',
      'year': 'Prehistoric',
    },
    'N': {
      'discoveredBy': 'Daniel Rutherford',
      'namedBy': 'From Greek "nitron" and "-gen" (forming)',
      'year': '1772',
    },
    'O': {
      'discoveredBy': 'Carl Wilhelm Scheele, Joseph Priestley',
      'namedBy':
          'Antoine Lavoisier, from Greek "oxy" and "-gen" (acid-forming)',
      'year': '1771-1774',
    },
    'F': {
      'discoveredBy': 'André-Marie Ampère, Humphry Davy, Henri Moissan',
      'namedBy': 'From Latin "fluere" (to flow)',
      'year': '1886',
    },
    'Ne': {
      'discoveredBy': 'Sir William Ramsay, Morris Travers',
      'namedBy': 'From Greek "neos" (new)',
      'year': '1898',
    },
    'Na': {
      'discoveredBy': 'Humphry Davy',
      'namedBy': 'From English "soda" (natrium in Latin)',
      'year': '1807',
    },
    'Mg': {
      'discoveredBy': 'Joseph Black, Humphry Davy',
      'namedBy': 'From Magnesia, a district in Greece',
      'year': '1755',
    },
    'Al': {
      'discoveredBy': 'Hans Christian Ørsted',
      'namedBy': 'From "alumen" (alum)',
      'year': '1825',
    },
    'Si': {
      'discoveredBy': 'Jöns Jacob Berzelius',
      'namedBy': 'From Latin "silex" (flint)',
      'year': '1824',
    },
    'P': {
      'discoveredBy': 'Hennig Brand',
      'namedBy': 'From Greek "phosphoros" (light-bearing)',
      'year': '1669',
    },
    'S': {
      'discoveredBy': 'Known to antiquity',
      'namedBy': 'From Latin "sulphur"',
      'year': 'Prehistoric',
    },
    'Cl': {
      'discoveredBy': 'Carl Wilhelm Scheele',
      'namedBy': 'From Greek "chloros" (greenish-yellow)',
      'year': '1774',
    },
    'Ar': {
      'discoveredBy': 'Lord Rayleigh, Sir William Ramsay',
      'namedBy': 'From Greek "argos" (idle)',
      'year': '1894',
    },
    'K': {
      'discoveredBy': 'Humphry Davy',
      'namedBy': 'From English "potash" (kalium in Latin)',
      'year': '1807',
    },
    'Ca': {
      'discoveredBy': 'Humphry Davy',
      'namedBy': 'From Latin "calx" (lime)',
      'year': '1808',
    },
    'Fe': {
      'discoveredBy': 'Known to antiquity',
      'namedBy': 'From Latin "ferrum"',
      'year': 'Prehistoric',
    },
    'Cu': {
      'discoveredBy': 'Known to antiquity',
      'namedBy': 'From Latin "cuprum" (Cyprus)',
      'year': 'Prehistoric',
    },
    'Ag': {
      'discoveredBy': 'Known to antiquity',
      'namedBy': 'From Latin "argentum"',
      'year': 'Prehistoric',
    },
    'Au': {
      'discoveredBy': 'Known to antiquity',
      'namedBy': 'From Latin "aurum"',
      'year': 'Prehistoric',
    },
    'Hg': {
      'discoveredBy': 'Known to antiquity',
      'namedBy': 'From Latin "hydrargyrum" (liquid silver)',
      'year': 'Prehistoric',
    },
    'Pb': {
      'discoveredBy': 'Known to antiquity',
      'namedBy': 'From Latin "plumbum"',
      'year': 'Prehistoric',
    },
    'U': {
      'discoveredBy': 'Martin Heinrich Klaproth',
      'namedBy': 'After the planet Uranus',
      'year': '1789',
    },
    // Period 3 elements missing from original data
    'Sc': {
      'discoveredBy': 'Lars Fredrik Nilson',
      'namedBy': 'From Latin "Scandia" (Scandinavia)',
      'year': '1879',
    },
    'Ti': {
      'discoveredBy': 'William Gregor',
      'namedBy': 'Martin Heinrich Klaproth, from "Titans" in Greek mythology',
      'year': '1791',
    },
    'V': {
      'discoveredBy': 'Andrés Manuel del Río, Nils Gabriel Sefström',
      'namedBy': 'From "Vanadis" (Norse goddess)',
      'year': '1801, rediscovered 1830',
    },
    'Cr': {
      'discoveredBy': 'Louis Nicolas Vauquelin',
      'namedBy': 'From Greek "chroma" (color)',
      'year': '1797',
    },
    'Mn': {
      'discoveredBy': 'Johan Gottlieb Gahn',
      'namedBy': 'From Latin "magnes" (magnet)',
      'year': '1774',
    },
    'Co': {
      'discoveredBy': 'Georg Brandt',
      'namedBy': 'From German "Kobold" (goblin)',
      'year': '1735',
    },
    'Ni': {
      'discoveredBy': 'Axel Fredrik Cronstedt',
      'namedBy': 'From German "Kupfernickel" (false copper)',
      'year': '1751',
    },
    'Zn': {
      'discoveredBy':
          'Known to antiquity in alloy form, isolated by Andreas Sigismund Marggraf',
      'namedBy': 'From German "Zink"',
      'year': 'Known since ancient times, isolated 1746',
    },
    'Ga': {
      'discoveredBy': 'Paul Émile Lecoq de Boisbaudran',
      'namedBy': 'From Latin "Gallia" (France)',
      'year': '1875',
    },
    'Ge': {
      'discoveredBy': 'Clemens Winkler',
      'namedBy': 'From Latin "Germania" (Germany)',
      'year': '1886',
    },
    'As': {
      'discoveredBy': 'Known to antiquity',
      'namedBy': 'From Latin "arsenicum"',
      'year': 'Prehistoric',
    },
    'Se': {
      'discoveredBy': 'Jöns Jakob Berzelius',
      'namedBy': 'From Greek "selene" (moon)',
      'year': '1817',
    },
    'Br': {
      'discoveredBy': 'Antoine Jérôme Balard',
      'namedBy': 'From Greek "bromos" (stench)',
      'year': '1826',
    },
    'Kr': {
      'discoveredBy': 'Sir William Ramsay, Morris Travers',
      'namedBy': 'From Greek "kryptos" (hidden)',
      'year': '1898',
    },

    // Period 4 and beyond (selected important elements)
    'Rb': {
      'discoveredBy': 'Robert Bunsen, Gustav Kirchhoff',
      'namedBy': 'From Latin "rubidus" (deep red)',
      'year': '1861',
    },
    'Sr': {
      'discoveredBy': 'Adair Crawford',
      'namedBy': 'From Strontian, Scotland',
      'year': '1790',
    },
    'Y': {
      'discoveredBy': 'Johan Gadolin',
      'namedBy': 'From Ytterby, Sweden',
      'year': '1794',
    },
    'Zr': {
      'discoveredBy': 'Martin Heinrich Klaproth',
      'namedBy': 'From Persian "zargun" (gold-colored)',
      'year': '1789',
    },
    'Nb': {
      'discoveredBy': 'Charles Hatchett',
      'namedBy': 'From Niobe in Greek mythology',
      'year': '1801',
    },
    'Mo': {
      'discoveredBy': 'Carl Wilhelm Scheele',
      'namedBy': 'From Greek "molybdos" (lead)',
      'year': '1778',
    },
    'Tc': {
      'discoveredBy': 'Carlo Perrier, Emilio Segrè',
      'namedBy': 'From Greek "technetos" (artificial)',
      'year': '1937',
    },
    'Ru': {
      'discoveredBy': 'Karl Ernst Claus',
      'namedBy': 'From Latin "Ruthenia" (Russia)',
      'year': '1844',
    },
    'Rh': {
      'discoveredBy': 'William Hyde Wollaston',
      'namedBy': 'From Greek "rhodon" (rose)',
      'year': '1803',
    },
    'Pd': {
      'discoveredBy': 'William Hyde Wollaston',
      'namedBy': 'From asteroid Pallas',
      'year': '1803',
    },
    'Cd': {
      'discoveredBy': 'Friedrich Stromeyer',
      'namedBy': 'From Greek "kadmeia" (calamine)',
      'year': '1817',
    },
    'In': {
      'discoveredBy': 'Ferdinand Reich, Hieronymous Theodor Richter',
      'namedBy': 'From indigo color in its spectrum',
      'year': '1863',
    },
    'Sn': {
      'discoveredBy': 'Known to antiquity',
      'namedBy': 'From Latin "stannum"',
      'year': 'Prehistoric',
    },
    'Sb': {
      'discoveredBy': 'Known to antiquity',
      'namedBy': 'From Latin "stibium"',
      'year': 'Prehistoric',
    },
    'Te': {
      'discoveredBy': 'Franz-Joseph Müller von Reichenstein',
      'namedBy': 'From Latin "tellus" (earth)',
      'year': '1782',
    },
    'I': {
      'discoveredBy': 'Bernard Courtois',
      'namedBy': 'From Greek "iodes" (violet)',
      'year': '1811',
    },
    'Xe': {
      'discoveredBy': 'Sir William Ramsay, Morris Travers',
      'namedBy': 'From Greek "xenos" (stranger)',
      'year': '1898',
    },
    'Cs': {
      'discoveredBy': 'Robert Bunsen, Gustav Kirchhoff',
      'namedBy': 'From Latin "caesius" (sky blue)',
      'year': '1860',
    },
    'Ba': {
      'discoveredBy': 'Sir Humphry Davy',
      'namedBy': 'From Greek "barys" (heavy)',
      'year': '1808',
    },
    'La': {
      'discoveredBy': 'Carl Gustaf Mosander',
      'namedBy': 'From Greek "lanthanein" (to lie hidden)',
      'year': '1839',
    },
    'Ce': {
      'discoveredBy': 'Jöns Jakob Berzelius, Wilhelm Hisinger',
      'namedBy': 'From asteroid Ceres',
      'year': '1803',
    },
    'Pt': {
      'discoveredBy': 'Antonio de Ulloa',
      'namedBy': 'From Spanish "platina" (little silver)',
      'year': '1735',
    },
    'W': {
      'discoveredBy': 'Carl Wilhelm Scheele',
      'namedBy': 'From Swedish "tung sten" (heavy stone), symbol from Wolfram',
      'year': '1783',
    },
    'Os': {
      'discoveredBy': 'Smithson Tennant',
      'namedBy': 'From Greek "osme" (smell)',
      'year': '1803',
    },
    'Ir': {
      'discoveredBy': 'Smithson Tennant',
      'namedBy': 'From Greek "iris" (rainbow)',
      'year': '1803',
    },
    'Tl': {
      'discoveredBy': 'Sir William Crookes',
      'namedBy': 'From Greek "thallos" (green twig)',
      'year': '1861',
    },
    'Bi': {
      'discoveredBy':
          'Known to antiquity, but often confused with lead and tin',
      'namedBy': 'From German "Wismuth"',
      'year': 'Known since medieval times',
    },
    'Po': {
      'discoveredBy': 'Marie and Pierre Curie',
      'namedBy': 'After Poland (Marie Curie\'s native country)',
      'year': '1898',
    },
    'Rn': {
      'discoveredBy': 'Friedrich Ernst Dorn',
      'namedBy': 'From "radium emanation", later renamed to radon',
      'year': '1900',
    },
    'Fr': {
      'discoveredBy': 'Marguerite Perey',
      'namedBy': 'After France',
      'year': '1939',
    },
    'Ra': {
      'discoveredBy': 'Marie and Pierre Curie',
      'namedBy': 'From Latin "radius" (ray)',
      'year': '1898',
    },
    'Ac': {
      'discoveredBy': 'André-Louis Debierne',
      'namedBy': 'From Greek "aktinos" (ray)',
      'year': '1899',
    },
    'Th': {
      'discoveredBy': 'Jöns Jakob Berzelius',
      'namedBy': 'After Thor (Norse god)',
      'year': '1829',
    },
    'Pa': {
      'discoveredBy':
          'Kasimir Fajans, Otto Göhring, later by Lise Meitner and Otto Hahn',
      'namedBy': 'From Greek "proto" and "actinium"',
      'year': '1913/1917',
    },
    'Np': {
      'discoveredBy': 'Edwin McMillan, Philip Abelson',
      'namedBy': 'After the planet Neptune',
      'year': '1940',
    },
    'Pu': {
      'discoveredBy':
          'Glenn Seaborg, Arthur Wahl, Joseph Kennedy, Edwin McMillan',
      'namedBy': 'After the planet Pluto',
      'year': '1940',
    },
    'Am': {
      'discoveredBy': 'Glenn Seaborg, Ralph James, Leon Morgan, Albert Ghiorso',
      'namedBy': 'After America',
      'year': '1944',
    },
  };

  // Get description for an element by symbol
  static String getDescription(String symbol) {
    return descriptions[symbol] ??
        'No detailed description available for this element.';
  }

  // Get discovery info for an element
  static Map<String, String> getDiscoveryInfo(String symbol) {
    return discoveryInfo[symbol] ??
        {
          'discoveredBy': 'N/A',
          'namedBy': 'N/A',
          'year': 'N/A',
        };
  }
}
