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
package guice
{
import guice.binding.AbstractBinding;
import guice.binding.Binder;
import guice.reflection.InjectionPoint;
import guice.reflection.MethodInjectionPoint;
import guice.reflection.TypeDefinition;
import guice.resolver.ClassResolver;

public class Injector {
		protected var binder:Binder;
		protected var classResolver:ClassResolver;

		public function getInstance( dependency:Class ):Object {
			return resolveDependency( new TypeDefinition(dependency), {} );
		}

		public function getInstanceByDefinition( dependencyTypeDefinition:TypeDefinition ):* {
			return resolveDependency(dependencyTypeDefinition, {} );
		}
		
		internal function getBinding( typeDefinition:TypeDefinition ):AbstractBinding  {
			return binder.getBinding( typeDefinition );
		}
		
		//Entry point for TypeAbstractBinding to ask for a class.... 
		//This method does so without trying to resolve the class first, which is important if we are called from within a resolution
		public function buildClass(typeDefinition:TypeDefinition, watcher:Object ):* {
			var instance:Object;
			
			if (typeDefinition.builtIn) {
				instance = typeDefinition.constructorApply(null);
			} else {
				watcher[ typeDefinition.getClassName() ] = true;

				var constructorPoints:Vector.<InjectionPoint> = typeDefinition.getConstructorParameters();
				instance = buildFromInjectionInfo(typeDefinition, constructorPoints, watcher );
				
				var fieldPoints:Vector.<InjectionPoint> = typeDefinition.getInjectionFields();
				injectMemberPropertiesFromInjectionInfo(instance, fieldPoints, watcher );
				
				var methodPoints:Vector.<MethodInjectionPoint> = typeDefinition.getInjectionMethods();
				injectMembersMethodsFromInjectionInfo(instance, methodPoints, watcher);

				delete watcher[ typeDefinition.getClassName() ];
			}
			
			return instance;
		}
		
		public function injectMembers( instance:* ):void {
			var constructor:* = instance.constructor;
			
			var typeDefinition:TypeDefinition = new TypeDefinition(constructor);

			var watcher:Object = new Object();
			var fieldPoints:Vector.<InjectionPoint> = typeDefinition.getInjectionFields();
			injectMemberPropertiesFromInjectionInfo(instance, fieldPoints, watcher);
			
			var methodPoints:Vector.<MethodInjectionPoint> = typeDefinition.getInjectionMethods();
			injectMembersMethodsFromInjectionInfo(instance, methodPoints, watcher);
		}
		
		private function buildFromInjectionInfo(dependencyTypeDefinition:TypeDefinition, constructorPoints:Vector.<InjectionPoint>, watcher:Object ):* {
			var args:Array = new Array();
			
			for (var i:int = 0; i < constructorPoints.length; i++) {
				args[i] = resolveDependency(classResolver.resolveClassName(constructorPoints[i].t, watcher), watcher);
			}
			
			return dependencyTypeDefinition.constructorApply(args);;
		}
		
		private function injectMemberPropertiesFromInjectionInfo(instance:*, fieldPoints:Vector.<InjectionPoint>, watcher:Object):void {
			for (var i:int = 0; i < fieldPoints.length; i++) {
				instance[fieldPoints[i].n] = resolveDependency(classResolver.resolveClassName(fieldPoints[i].t, watcher), watcher);
			}
		}
		
		private function injectMembersMethodsFromInjectionInfo(instance:*, methodPoints:Vector.<MethodInjectionPoint>, watcher:Object ):void {
			
			for (var i:int = 0; i < methodPoints.length; i++) {
				var methodPoint:MethodInjectionPoint = methodPoints[i];
				var args:Array = new Array();
				
				for (var j:int = 0; j < methodPoint.p.length; j++) {
					var parameterPoint:InjectionPoint = methodPoint.p[j];
					args[j] = resolveDependency(classResolver.resolveClassName(parameterPoint.t,watcher),watcher);
				}
				
				var action:Function = instance[methodPoints[i].n];
				action.apply(instance, args);
			}
		}		
		
		private function resolveDependency(typeDefinition:TypeDefinition, watcher:Object ):Object {
			var abstractBinding:AbstractBinding = null;

			if ( watcher[ typeDefinition.getClassName() ] ) {
				throw new Error("Circular Reference While Resolving : " + typeDefinition.getClassName() );
			}

			if ( !typeDefinition.builtIn ) {
				abstractBinding = getBinding(typeDefinition);
			}
			
			var instance:Object;
			
			if (abstractBinding != null) {
				instance = abstractBinding.provide(this);
			} else {
				instance = buildClass(typeDefinition, watcher);
			}
			
			return instance;
		}		
		
		public function Injector(binder:Binder, classResolver:ClassResolver) {
			this.binder = binder;
			this.classResolver = classResolver;
		}
		
	}
}