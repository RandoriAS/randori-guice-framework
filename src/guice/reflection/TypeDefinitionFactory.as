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
package guice.reflection {
import randori.webkit.page.Window;

public class TypeDefinitionFactory {

	private function findDefinition(qualifiedClassName:String):Object {
		var nextLevel:* = Window.window;
		var failed:Boolean = false;

		if ( qualifiedClassName.charAt(0) == "*" ) {
			qualifiedClassName = qualifiedClassName.substr( 1 );
		}

		var path:Array = qualifiedClassName.split('.');

		for (var i:int = 0; i < path.length; i++) {
			nextLevel = nextLevel[path[i]];
			if (!nextLevel) {
				failed = true;
				break;
			}
		}

		if (failed) {
			return null;
		}

		return nextLevel;
	}

	private function createEmptyDefinition(qualifiedClassName:String):Object {
		var nextLevel:* = Window.window;
		var neededLevel:*;

		if ( qualifiedClassName.charAt(0) == "*" ) {
			qualifiedClassName = qualifiedClassName.substr( 1 );
		}

		var path:Array = qualifiedClassName.split('.');

		for (var i:int = 0; i < path.length; i++) {
			neededLevel = nextLevel[path[i]];
			if (!neededLevel) {
				nextLevel[ path[i] ] = neededLevel = {};
			}
			nextLevel = neededLevel;
		}

		return neededLevel;
	}

	private function buildProxyObjectForDependency( qualifiedClassName:String ):* {
		var proxy:* = createEmptyDefinition( qualifiedClassName );

		//if we have a className, we already have this class, no need to make a proxy
		if ( !proxy.className ) {
			proxy.className = qualifiedClassName;
			proxy.isProxy = true;
		}

		return proxy;
	}

	public function getDefinitionForName( name:String ):TypeDefinition {
		var type:* = findDefinition( name );
		var typeDefinition:TypeDefinition;

		if ( type != null ) {
			typeDefinition = getDefinitionForType( type );
		} else {
			typeDefinition = getDefinitionForType( buildProxyObjectForDependency( name ) );
		}

		return typeDefinition;
	}

	public function getDefinitionForType( type:Class ):TypeDefinition {
		return new TypeDefinition( type );
	}

	public function TypeDefinitionFactory() {
	}
}
}