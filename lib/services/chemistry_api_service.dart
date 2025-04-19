// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../screens/chemistryguide/model/chemistry_guide.dart';
// import 'wikipedia_service.dart';

// class ChemistryApiService {
//   static const String _baseUrl = 'https://pubchem.ncbi.nlm.nih.gov/rest/pug';
//   static const String _pugViewUrl =
//       'https://pubchem.ncbi.nlm.nih.gov/rest/pug_view';

//   final WikipediaService _wikipediaService = WikipediaService();

//   // Maximum number of concurrent requests to avoid overloading PubChem servers
//   static const int _maxConcurrentRequests = 5;
//   static const Duration _requestThrottle =
//       Duration(milliseconds: 250); // 4 requests per second

//   // PUG View - Get detailed element data
//   Future<Map<String, dynamic>> getElementDetailsByNumber(
//       int atomicNumber) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$_pugViewUrl/data/element/$atomicNumber/JSON'),
//       );

//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw Exception(
//             'Failed to load element details: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error fetching element details: $e');
//     }
//   }

//   // PUG View - Get compound details with a specific heading
//   Future<Map<String, dynamic>> getCompoundDetailsWithHeading(
//       int cid, String heading) async {
//     try {
//       // URL encode the heading
//       final encodedHeading = Uri.encodeComponent(heading);

//       final response = await http.get(
//         Uri.parse(
//             '$_pugViewUrl/data/compound/$cid/JSON?heading=$encodedHeading'),
//       );

//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw Exception(
//             'Failed to load compound details with heading: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error fetching compound details: $e');
//     }
//   }

//   // PUG View - Get annotations for a specific heading
//   Future<Map<String, dynamic>> getAnnotationsByHeading(String heading,
//       {int page = 1}) async {
//     try {
//       final encodedHeading = Uri.encodeComponent(heading);

//       final response = await http.get(
//         Uri.parse(
//             '$_pugViewUrl/annotations/heading/JSON?heading=$encodedHeading&page=$page'),
//       );

//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to load annotations: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error fetching annotations: $e');
//     }
//   }

//   // PUG View - Get list of all annotation headings
//   Future<List<String>> getAllAnnotationHeadings() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$_pugViewUrl/annotations/headings/JSON'),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         List<String> headings = [];

//         if (data is Map && data.containsKey('Headings')) {
//           final headingsData = data['Headings'];
//           if (headingsData is List) {
//             for (final heading in headingsData) {
//               if (heading is Map && heading.containsKey('Heading')) {
//                 headings.add(heading['Heading'].toString());
//               }
//             }
//           }
//         }

//         return headings;
//       } else {
//         throw Exception(
//             'Failed to load annotation headings: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error fetching annotation headings: $e');
//     }
//   }

//   // PUG View - Get pathway information
//   Future<Map<String, dynamic>> getPathwayDetails(
//       String source, String externalId) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$_pugViewUrl/data/pathway/$source:$externalId/JSON'),
//       );

//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw Exception(
//             'Failed to load pathway details: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error fetching pathway details: $e');
//     }
//   }

//   // Fetch data about a single element by symbol
//   Future<ChemistryElement?> getElementBySymbol(String symbol) async {
//     try {
//       // PubChem doesn't have a direct elements API, but we can extract from periodic table
//       final response = await http.get(
//         Uri.parse(
//             'https://pubchem.ncbi.nlm.nih.gov/rest/pug/periodictable/JSON'),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final elements = data['Table']['Row'] ?? [];

//         for (final element in elements) {
//           if (element['Symbol'] == symbol) {
//             return ChemistryElement.fromJson(element);
//           }
//         }
//       }
//       return null;
//     } catch (e) {
//       throw Exception('Failed to load element data: $e');
//     }
//   }

//   // Fetch all elements from periodic table
//   Future<List<ChemistryElement>> getAllElements() async {
//     try {
//       final response = await http.get(
//         Uri.parse(
//             'https://pubchem.ncbi.nlm.nih.gov/rest/pug/periodictable/JSON'),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final elementsJson = data['Table']['Row'] ?? [];
//         List<ChemistryElement> elements = [];

//         for (final element in elementsJson) {
//           elements.add(ChemistryElement.fromJson(element));
//         }
//         return elements;
//       } else {
//         throw Exception('Failed to load periodic table data');
//       }
//     } catch (e) {
//       throw Exception('Failed to load periodic table data: $e');
//     }
//   }

//   // Fetch compound information by CID
//   Future<ChemicalCompound?> getCompoundByCid(int cid) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$_baseUrl/compound/cid/$cid/record/JSON'),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         return ChemicalCompound.fromJson(data);
//       } else {
//         return null;
//       }
//     } catch (e) {
//       throw Exception('Failed to load compound data: $e');
//     }
//   }

//   // Fetch compound information by name
//   Future<List<ChemicalCompound>> searchCompoundsByName(String name) async {
//     try {
//       // First get the CIDs for the compound name
//       final searchResponse = await http.get(
//         Uri.parse('$_baseUrl/compound/name/$name/cids/JSON'),
//       );

//       if (searchResponse.statusCode == 200) {
//         final searchData = json.decode(searchResponse.body);
//         final cids = searchData['IdentifierList']['CID'] ?? [];

//         List<ChemicalCompound> compounds = [];

//         // Get first 5 compounds to avoid too many requests
//         final cisList = cids.take(_maxConcurrentRequests).toList();

//         for (final cid in cisList) {
//           final compound = await getCompoundByCid(cid);
//           if (compound != null) {
//             compounds.add(compound);
//           }
//           // Add delay to respect PubChem rate limits
//           await Future.delayed(_requestThrottle);
//         }

//         return compounds;
//       } else {
//         return [];
//       }
//     } catch (e) {
//       throw Exception('Failed to search compounds: $e');
//     }
//   }

//   // Fetch compound properties by CID
//   Future<List<ChemicalProperty>> getCompoundProperties(int cid) async {
//     try {
//       final response = await http.get(
//         Uri.parse(
//             '$_baseUrl/compound/cid/$cid/property/MolecularFormula,MolecularWeight,XLogP,TPSA,HBondDonorCount,HBondAcceptorCount,RotatableBondCount,MonoisotopicMass/JSON'),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final properties = data['PropertyTable']['Properties'][0] ?? {};

//         List<ChemicalProperty> result = [];

//         properties.forEach((key, value) {
//           result.add(ChemicalProperty(
//             name: key,
//             value: value.toString(),
//           ));
//         });

//         return result;
//       } else {
//         return [];
//       }
//     } catch (e) {
//       throw Exception('Failed to load compound properties: $e');
//     }
//   }

//   // PUG View - Get chemical reactions (custom model)
//   Future<List<ChemicalReaction>> getReactionsByType(String reactionType) async {
//     try {
//       final encodedType = Uri.encodeComponent(reactionType);
//       final response = await http.get(
//         Uri.parse(
//             '$_pugViewUrl/annotations/heading/JSON?heading=Chemical+Reactions&subheading=$encodedType'),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         // Handle custom parsing to ChemicalReaction objects
//         List<ChemicalReaction> reactions = [];

//         // This would require custom parsing based on the actual response structure
//         // The implementations will depend on the exact format of reactions in PubChem

//         return reactions;
//       } else {
//         return [];
//       }
//     } catch (e) {
//       throw Exception('Failed to load reactions: $e');
//     }
//   }

//   // Get sample elements for each category
//   Future<Map<String, List<ChemistryElement>>> getElementCategories() async {
//     final allElements = await getAllElements();

//     // Group elements by category
//     Map<String, List<ChemistryElement>> categories = {};

//     for (final element in allElements) {
//       if (categories[element.category] == null) {
//         categories[element.category] = [];
//       }
//       categories[element.category]!.add(element);
//     }

//     return categories;
//   }

//   // Get common compounds for educational purposes
//   Future<List<ChemicalCompound>> getCommonCompounds() async {
//     // List of CIDs for common compounds used in chemistry education
//     List<int> commonCompoundCids = [
//       962, // Water
//       280, // Ethanol
//       887, // Glucose
//       5793, // Aspirin
//       2244, // Caffeine
//       222, // Acetic Acid
//       6324, // NaCl (Salt)
//       767, // Carbon Dioxide
//     ];

//     List<ChemicalCompound> compounds = [];

//     for (final cid in commonCompoundCids) {
//       try {
//         final compound = await getCompoundByCid(cid);
//         if (compound != null) {
//           compounds.add(compound);
//         }
//         // Add delay to respect PubChem rate limits
//         await Future.delayed(_requestThrottle);
//       } catch (e) {
//         print('Error fetching compound $cid: $e');
//       }
//     }

//     return compounds;
//   }

//   // PUG View - Get related literature for compounds
//   Future<Map<String, dynamic>> getCompoundLiterature(int cid) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$_pugViewUrl/literature/compound/$cid/JSON'),
//       );

//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw Exception(
//             'Failed to load compound literature: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error fetching compound literature: $e');
//     }
//   }

//   // PUG View - Get 3D protein structures associated with a compound
//   Future<Map<String, dynamic>> getCompoundStructures(int cid) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$_pugViewUrl/structure/compound/$cid/JSON'),
//       );

//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw Exception(
//             'Failed to load compound 3D structures: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error fetching compound 3D structures: $e');
//     }
//   }

//   // Wikipedia integration methods

//   /// Fetch Wikipedia article for a chemistry concept or term
//   Future<WikipediaArticle?> getChemistryTopicFromWikipedia(String topic) async {
//     try {
//       final articleData = await _wikipediaService.getArticleSummary(topic);
//       return WikipediaArticle.fromJson(articleData);
//     } catch (e) {
//       print('Error fetching Wikipedia article for $topic: $e');
//       return null;
//     }
//   }

//   /// Search Wikipedia for chemistry-related topics
//   Future<List<String>> searchChemistryTopics(String query) async {
//     try {
//       // First try with Chemistry prefix to focus results
//       final chemistryQuery = 'Chemistry $query';
//       final results =
//           await _wikipediaService.searchArticles(chemistryQuery, limit: 5);

//       // If we don't get enough results, try the original query
//       if (results.length < 3) {
//         final additionalResults =
//             await _wikipediaService.searchArticles(query, limit: 5);
//         return [
//           ...results,
//           ...additionalResults.where((r) => !results.contains(r))
//         ].take(10).toList();
//       }

//       return results;
//     } catch (e) {
//       print('Error searching Wikipedia: $e');
//       return [];
//     }
//   }

 
// }
