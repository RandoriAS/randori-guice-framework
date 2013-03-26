/***
 * Copyright 2012 LTN Consulting, Inc. /dba Digital Primates®
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
package guice.utilities {
	public class InjectionDecorator {
		/* Decorates an arbitrary object to allow it to be injected by guice */
		public function decorateObject(dependency:*, className:String ):void {
			var injectableType:InjectableType = dependency;
			
			injectableType.injectionPoints = defaultInjectionPoints;
			injectableType.getClassDependencies = getClassDependencies;
			injectableType.className = className;
		}
		
		private static function defaultInjectionPoints(t:*):void  {
		}
		
		private static function getClassDependencies():Array {
			return new Array();
		}
		
		public function InjectionDecorator() {
		}
	}
}

[JavaScript(export="false")]
class InjectableType {
	public var className:String;
	public var injectionPoints:Function;
	public var getClassDependencies:Function;
}
