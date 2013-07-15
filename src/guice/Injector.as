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
import guice.binding.IBinder;
import guice.binding.IBinding;
import guice.reflection.InjectionPoint;
import guice.reflection.MethodInjectionPoint;
import guice.reflection.TypeDefinition;
import guice.reflection.TypeDefinitionFactory;
import guice.resolver.CircularDependencyMap;
import guice.resolver.IClassResolver;

public class Injector implements IInjector {
	protected var binder:IBinder;
	protected var classResolver:IClassResolver;
	private var factory:TypeDefinitionFactory;

	public function getInstance(dependency:Class):* {
		return resolveDependency(factory.getDefinitionForType(dependency), new CircularDependencyMap());
	}

	public function getInstanceByDefinition(dependencyTypeDefinition:TypeDefinition):* {
		return resolveDependency(dependencyTypeDefinition, new CircularDependencyMap());
	}

	public function getBinding(typeDefinition:TypeDefinition):IBinding {
		return binder.getBinding(typeDefinition);
	}

	public function buildClass(type:Class, circularDependencyMap:CircularDependencyMap):* {
		return buildClassFromDefinition( factory.getDefinitionForType( type ), new CircularDependencyMap() );
	}

		//Entry point for TypeAbstractBinding to ask for a class....
	//This method does so without trying to resolve the class first, which is important if we are called from within a resolution
	public function buildClassFromDefinition(typeDefinition:TypeDefinition, circularDependencyMap:CircularDependencyMap):* {
		var instance:Object;

		if (typeDefinition.builtIn) {
			instance = typeDefinition.constructorApply(null);
		} else {
			if (typeDefinition.isProxy) {
				//We need to resolve this proxy before continuing
				typeDefinition = classResolver.resolveProxy(typeDefinition, circularDependencyMap);
			} else {
				//Not sure if this should get added only in the case where we don't need to resolve
				circularDependencyMap[ typeDefinition.getClassName() ] = true;
			}

			var constructorPoints:Vector.<InjectionPoint> = typeDefinition.getConstructorParameters();
			instance = buildFromInjectionInfo(typeDefinition, constructorPoints, circularDependencyMap);

			var fieldPoints:Vector.<InjectionPoint> = typeDefinition.getInjectionFields();
			injectMemberPropertiesFromInjectionInfo(instance, fieldPoints, circularDependencyMap);

			var methodPoints:Vector.<MethodInjectionPoint> = typeDefinition.getInjectionMethods();
			injectMembersMethodsFromInjectionInfo(instance, methodPoints, circularDependencyMap);

			delete circularDependencyMap[ typeDefinition.getClassName() ];
		}

		return instance;
	}

	public function injectMembers( instance:* ):void {
		var constructor:* = instance.constructor;

		var typeDefinition:TypeDefinition = factory.getDefinitionForType( constructor );

		var circularDependencyMap:CircularDependencyMap = new CircularDependencyMap();
		var fieldPoints:Vector.<InjectionPoint> = typeDefinition.getInjectionFields();
		injectMemberPropertiesFromInjectionInfo(instance, fieldPoints, circularDependencyMap);

		var methodPoints:Vector.<MethodInjectionPoint> = typeDefinition.getInjectionMethods();
		injectMembersMethodsFromInjectionInfo(instance, methodPoints, circularDependencyMap);
	}

	private function buildFromInjectionInfo(dependencyTypeDefinition:TypeDefinition, constructorPoints:Vector.<InjectionPoint>, circularDependencyMap:CircularDependencyMap ):* {
		var args:Array = new Array();

		for (var i:int = 0; i < constructorPoints.length; i++) {

			args[i] = resolveDependency( factory.getDefinitionForName( constructorPoints[i].t ), circularDependencyMap);
		}

		//ARGS NEED TO BE RESOLVED BY THIS POINT
		return dependencyTypeDefinition.constructorApply( args );;
	}

	private function injectMemberPropertiesFromInjectionInfo(instance:*, fieldPoints:Vector.<InjectionPoint>, circularDependencyMap:CircularDependencyMap ):void {
		for (var i:int = 0; i < fieldPoints.length; i++) {
			instance[ fieldPoints[ i ].n ] = resolveDependency( factory.getDefinitionForName( fieldPoints[i].t ), circularDependencyMap );
		}
	}

	private function injectMembersMethodsFromInjectionInfo(instance:*, methodPoints:Vector.<MethodInjectionPoint>, circularDependencyMap:CircularDependencyMap ):void {

		for (var i:int = 0; i < methodPoints.length; i++) {
			var methodPoint:MethodInjectionPoint = methodPoints[i];
			var args:Array = new Array();

			for (var j:int = 0; j < methodPoint.p.length; j++) {
				var parameterPoint:InjectionPoint = methodPoint.p[ j ];
				args[ j ] = resolveDependency( factory.getDefinitionForName( parameterPoint.t ),circularDependencyMap );
			}

			var action:Function = instance[ methodPoints[i].n ];
			action.apply( instance, args );
		}
	}

	private function resolveDependency( typeDefinition:TypeDefinition, circularDependencyMap:CircularDependencyMap ):Object {
		var abstractBinding:IBinding = null;

		if ( circularDependencyMap[ typeDefinition.getClassName() ] ) {
			throw new Error("Circular Reference While Resolving : " + typeDefinition.getClassName() );
		}

		if ( !typeDefinition.builtIn ) {
			abstractBinding = getBinding( typeDefinition );
		}

		var instance:Object;

		if (abstractBinding != null) {
			instance = abstractBinding.provide( this );
		} else {
			instance = buildClassFromDefinition( typeDefinition, circularDependencyMap );
		}

		return instance;
	}

	//Used in a child injector situation to configure a binder with a module at runtime
	public function configureBinder( module:IGuiceModule ):void {
		if (module != null) {
			module.configure(binder);
		}
	}

	public function Injector( binder:IBinder, classResolver:IClassResolver, factory:TypeDefinitionFactory ) {
		this.binder = binder;
		this.classResolver = classResolver;
		this.factory = factory;
	}
}
}