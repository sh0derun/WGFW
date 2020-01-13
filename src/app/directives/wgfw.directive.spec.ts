/* tslint:disable:no-unused-variable */

import { TestBed, async } from '@angular/core/testing';
import { WgfwDirective } from './wgfw.directive';

describe('Directive: Wgfw', () => {
  it('should create an instance', () => {
    const templateRef = jasmine.createSpyObj('TemplateRef', ['']);
    const directive = new WgfwDirective(templateRef);
    expect(directive).toBeTruthy();
  });
});
