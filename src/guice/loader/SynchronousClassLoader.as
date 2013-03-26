/***
 * Copyright 2013 LTN Consulting, Inc. /dba Digital Primates®
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 * 
 * @author Michael Labriola <labriola@digitalprimates.net>
 */
package guice.loader {
	import randori.webkit.xml.XMLHttpRequest;

	public class SynchronousClassLoader {
		private var xmlHttpRequest:XMLHttpRequest;
		private var dynamicClassBaseUrl:String;

		public function loadClass( qualifiedClassName:String ):String {
			var classNameRegex:RegExp = new RegExp("\\.", "g");
			var potentialURL:String = qualifiedClassName.replace(classNameRegex, "/");
			potentialURL = dynamicClassBaseUrl + potentialURL;
			potentialURL += ".js";
			
			xmlHttpRequest.open("GET", potentialURL, false);
			xmlHttpRequest.send();
			
			//Todo Need to handle other status than just 404
			if (xmlHttpRequest.status == 404) {
				//Todo This alert shouldnt be here, we should figure out a way to get it to the UI level
				//HtmlContext.alert("Required Class " + qualifiedClassName + " cannot be loaded.");
				throw new Error("Cannot continue, missing required class " + qualifiedClassName);
			}
			
			return ( xmlHttpRequest.responseText + "\n//@ sourceURL=" + potentialURL );
		}

		public function SynchronousClassLoader(xmlHttpRequest:randori.webkit.xml.XMLHttpRequest, dynamicClassBaseUrl:String) {
			this.xmlHttpRequest = xmlHttpRequest;
			this.dynamicClassBaseUrl = dynamicClassBaseUrl;
		}
	}
}